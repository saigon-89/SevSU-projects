#include <opencv2/opencv.hpp>
#include <iostream>
#include <fstream>
#include <cerrno>

/** Параметры обработки */
const int INPUT_WIDTH = 640;
const int INPUT_HEIGHT = 640;
const float SCORE_THRESHOLD      = 0.50;
const float NMS_THRESHOLD        = 0.45;
const float CONFIDENCE_THRESHOLD = 0.45;

/** Параметры шрифтов */
static const float FONT_SCALE = 0.7;
static const int   THICKNESS  = 1;

/** Цветовые константы */
static cv::Scalar BLACK  = cv::Scalar(0,   0,   0);
static cv::Scalar YELLOW = cv::Scalar(0, 255, 255);
static cv::Scalar RED    = cv::Scalar(0,   0, 255);
static cv::Scalar GREEN  = cv::Scalar(0, 255,   0);

/** Структура сегмента */
struct OutputSeg {
	int id;             // идентификатор класса
	float confidence;   // вероятность
	cv::Rect box;       // рамка сегмента
	cv::Mat boxMask;    // маска сегмента
};

/** Структура параметров маски */
struct MaskParams {
	int segChannels = 32;
	int segWidth = 160;
	int segHeight = 160;
	int netWidth = INPUT_WIDTH;
	int netHeight = INPUT_HEIGHT;
	float maskThreshold = 0.5;
	cv::Size srcImgShape;
	cv::Vec4d params;
};

/** Класс сегментатора */
class NeuralNetSegmentator {
  private: 
    /** Структура нейросети */
    cv::dnn::Net network;
    /** Ширина и высота входного изображения */
    int input_width = 640;
    int input_height = 640;
    /** Вектор распознаваемых классов */
    std::vector<std::string> classes;
    /** Структуры для хранения результатов обработки */
    std::vector<int> classes_id_set;
    std::vector<cv::Rect> boxes_set;
    std::vector<float> confidences_set;
    std::vector<std::string> classes_set;
    std::vector<cv::Scalar> masks_colors_set;
    std::vector<cv::Mat> masks_set;
    /** Время обработки */
    float inference_time;
    /** Получить строковые значения классов */
    error_t read_classes(const std::string file_path);
    /** Инициализация нейросети */
    error_t init_network(const std::string model_path, 
                         const std::string classes_path);
    /** TODO */
    void letter_box(const cv::Mat& image, cv::Mat& outImage,
		                cv::Vec4d& params,
		                const cv::Size& newShape,
		                bool autoShape, bool scaleFill,
		                bool scaleUp, int stride);
    /** Отрисовка метки */
    void draw_label(cv::Mat& img, std::string label, int left, int top);
    /** TODO */
    void draw_result(cv::Mat& image, std::vector<OutputSeg> result,
                     std::vector<std::string> class_name);
    /** Предобработка результатов */
    std::vector<cv::Mat> pre_process(cv::Mat& img, cv::Vec4d& params);
    /** TODO */
    void get_mask(const cv::Mat& mask_proposals, const cv::Mat& mask_protos,
                  OutputSeg& output, const MaskParams& maskParams);
    /** Постобработка результатов */
    cv::Mat post_process(cv::Mat &img, std::vector<cv::Mat> &outputs, 
                         const std::vector<std::string> &class_name,
                         cv::Vec4d& params);
  public:
    NeuralNetSegmentator(const std::string model, const std::string classes, 
                         int width, int height);
    std::vector<float> get_confidences(void) { return confidences_set; }
    std::vector<cv::Rect> get_boxes(void) { return boxes_set; }
    std::vector<int> get_class_ids(void) { return classes_id_set; }
    std::vector<std::string> get_classes(void) { return classes_set; }
    std::vector<cv::Mat> get_masks(void) { return masks_set; }
    float get_inference(void) { return inference_time; }
    std::string get_info(void);
    cv::Mat process(cv::Mat &img);
};

NeuralNetSegmentator::NeuralNetSegmentator(const std::string model, const std::string classes, 
                                           int width = INPUT_WIDTH, int height = INPUT_HEIGHT) {
  input_width = width;
  input_height = height;
  if (!init_network(model, classes)) {
    std::cout << "Neural network been inited!" << std::endl;
    std::cout << "Input width: " << input_width << std::endl;
    std::cout << "Input height: " << input_height << std::endl;
  } else {
    std::cerr << "Failed to init neural network!" << std::endl;
  }
}

error_t NeuralNetSegmentator::read_classes(const std::string file_path) {
  std::ifstream classes_file(file_path);
  std::string line;
  srand(time(0));

  if (!classes_file) {
    std::cerr << "Failed to open classes names!\n";
    return ENOENT;
  }
  while (std::getline(classes_file, line)) {
    classes.push_back(line);
		masks_colors_set.push_back(cv::Scalar(rand() % 256, rand() % 256, rand() % 256));
  }
  classes_file.close();

  return 0;
}

error_t NeuralNetSegmentator::init_network(const std::string model_path, 
                                           const std::string classes_path) {
  error_t err = read_classes(classes_path);

  if (err == 0) {
    network = cv::dnn::readNetFromONNX(model_path);
    if (network.empty()) {
      return ENETDOWN;
    } else {
      network.setPreferableBackend(cv::dnn::DNN_BACKEND_DEFAULT);
      network.setPreferableTarget(cv::dnn::DNN_TARGET_CPU);
    }
  }
  
  return err;
}

void NeuralNetSegmentator::letter_box(const cv::Mat& img, cv::Mat& out,
		                                  cv::Vec4d& params,
		                                  const cv::Size& newShape = cv::Size(INPUT_WIDTH, INPUT_HEIGHT),
		                                  bool autoShape = false, bool scaleFill = false,
		                                  bool scaleUp = true, int stride = 32) {
	cv::Size shape = img.size();
	float r = std::min((float)newShape.height / (float)shape.height, (float)newShape.width / (float)shape.width);
	if (!scaleUp) {
		r = std::min(r, 1.0f);
	}

	float ratio[2] = { r, r };
	int new_un_pad[2] = { (int)std::round((float)shape.width * r),
	                      (int)std::round((float)shape.height * r) };
	auto dw = (float)(newShape.width - new_un_pad[0]);
	auto dh = (float)(newShape.height - new_un_pad[1]);

	if (autoShape) {
		dw = (float)((int)dw % stride);
		dh = (float)((int)dh % stride);
	} else if (scaleFill) {
		dw = 0.0f;
		dh = 0.0f;
		new_un_pad[0] = newShape.width;
		new_un_pad[1] = newShape.height;
		ratio[0] = (float)newShape.width / (float)shape.width;
		ratio[1] = (float)newShape.height / (float)shape.height;
	}

	if (shape.width != new_un_pad[0] && shape.height != new_un_pad[1]) {
		cv::resize(img, out, cv::Size(new_un_pad[0], new_un_pad[1]));
	} else { 
		out = img.clone();
  }

	dw /= 2.0f;
	dh /= 2.0f;
	int top = int(std::round(dh - 0.1f));
	int bottom = int(std::round(dh + 0.1f));
	int left = int(std::round(dw - 0.1f));
	int right = int(std::round(dw + 0.1f));
	params[0] = ratio[0];
	params[1] = ratio[1];
	params[2] = left;
	params[3] = top;
	cv::copyMakeBorder(out, out, top, bottom, left, right, cv::BORDER_CONSTANT, BLACK);
}

std::vector<cv::Mat> NeuralNetSegmentator::pre_process(cv::Mat& img, cv::Vec4d& params) {
	cv::Mat input;
	cv::Mat blob;
	letter_box(img, input, params, cv::Size(INPUT_WIDTH, INPUT_HEIGHT));
	cv::dnn::blobFromImage(input, blob, 1.0 / 255.0, cv::Size(INPUT_WIDTH, INPUT_HEIGHT),
	                       cv::Scalar(), true, false);
	network.setInput(blob);
	std::vector<std::string> output_layer_names{ "output0", "output1" };
	std::vector<cv::Mat> outputs;
	network.forward(outputs, output_layer_names);
	return outputs;
}

void NeuralNetSegmentator::get_mask(const cv::Mat& mask_proposals, const cv::Mat& mask_protos,
                                    OutputSeg& output, const MaskParams& maskParams) {
	int seg_channels = maskParams.segChannels;
	int net_width = maskParams.netWidth;
	int seg_width = maskParams.segWidth;
	int net_height = maskParams.netHeight;
	int seg_height = maskParams.segHeight;
	float mask_threshold = maskParams.maskThreshold;
	cv::Vec4f params = maskParams.params;
	cv::Size src_img_shape = maskParams.srcImgShape;
	cv::Rect temp_rect = output.box;

	//crop from mask_protos
	int rang_x = floor((temp_rect.x * params[0] + params[2]) / net_width * seg_width);
	int rang_y = floor((temp_rect.y * params[1] + params[3]) / net_height * seg_height);
	int rang_w = ceil(((temp_rect.x + temp_rect.width) * params[0] + params[2]) / net_width * seg_width) - rang_x;
	int rang_h = ceil(((temp_rect.y + temp_rect.height) * params[1] + params[3]) / net_height * seg_height) - rang_y;

	rang_w = MAX(rang_w, 1);
	rang_h = MAX(rang_h, 1);
	if (rang_x + rang_w > seg_width) {
		if (seg_width - rang_x > 0) {
			rang_w = seg_width - rang_x;
		} else {
			rang_x -= 1;
		}
	}
	if (rang_y + rang_h > seg_height) {
		if (seg_height - rang_y > 0) {
			rang_h = seg_height - rang_y;
		} else {
			rang_y -= 1;
	  }
	}

	std::vector<cv::Range> roi_rangs;
	roi_rangs.push_back(cv::Range(0, 1));
	roi_rangs.push_back(cv::Range::all());
	roi_rangs.push_back(cv::Range(rang_y, rang_h + rang_y));
	roi_rangs.push_back(cv::Range(rang_x, rang_w + rang_x));

	//crop
	cv::Mat temp_mask_protos = mask_protos(roi_rangs).clone();
	cv::Mat protos = temp_mask_protos.reshape(0, { seg_channels,rang_w * rang_h });
	cv::Mat matmul_res = (mask_proposals * protos).t();
	cv::Mat masks_feature = matmul_res.reshape(1, { rang_h,rang_w });
	cv::Mat dest, mask;

	//sigmoid
	cv::exp(-masks_feature, dest);
	dest = 1.0 / (1.0 + dest);

	int left = floor((net_width / seg_width * rang_x - params[2]) / params[0]);
	int top = floor((net_height / seg_height * rang_y - params[3]) / params[1]);
	int width = ceil(net_width / seg_width * rang_w / params[0]);
	int height = ceil(net_height / seg_height * rang_h / params[1]);

	cv::resize(dest, mask, cv::Size(width, height), cv::INTER_NEAREST);
	mask = mask(temp_rect - cv::Point(left, top)) > mask_threshold;
	output.boxMask = mask;
}

// Draw the predicted bounding box.
void NeuralNetSegmentator::draw_label(cv::Mat& img, std::string label, int left, int top) {
  // Display the label at the top of the bounding box.
  int baseline;
  cv::Size label_size = cv::getTextSize(label, cv::FONT_HERSHEY_SIMPLEX, 
                                        FONT_SCALE, THICKNESS, &baseline);
  top = std::max(top, label_size.height);
  // Top left corner.
  cv::Point tlc = cv::Point(left, top);
  // Bottom right corner.
  cv::Point brc = cv::Point(left + label_size.width, 
                            top + label_size.height + baseline);
  // Draw black rectangle.
  cv::rectangle(img, tlc, brc, BLACK, cv::FILLED);
  // Put the label on the black rectangle.
  cv::putText(img, label, cv::Point(left, top + label_size.height), 
              cv::FONT_HERSHEY_SIMPLEX, FONT_SCALE, YELLOW, THICKNESS);
}

void NeuralNetSegmentator::draw_result(cv::Mat& img, std::vector<OutputSeg> result, std::vector<std::string> class_name) {
	cv::Mat mask = img.clone();
	for (int i = 0; i < result.size(); i++) {
		cv::rectangle(img, result[i].box, GREEN, 3*THICKNESS);
		mask(result[i].box).setTo(masks_colors_set[result[i].id], result[i].boxMask);
		std::string label = cv::format("%.2f", result[i].confidence);
    label = class_name[result[i].id] + ": " + label;
		int left = result[i].box.x;
    int top = result[i].box.y;
		draw_label(img, label, left, top);
	}
	cv::addWeighted(img, 0.5, mask, 0.5, 0, img);
}

cv::Mat NeuralNetSegmentator::post_process(cv::Mat &img, std::vector<cv::Mat> &outputs,
                                           const std::vector<std::string> &class_name,
                                           cv::Vec4d& params) {
	classes_id_set.clear();
  confidences_set.clear();
  boxes_set.clear();
  classes_set.clear();
  masks_set.clear();
	std::vector<int> class_ids;
	std::vector<float> confidences;
	std::vector<cv::Rect> boxes;
	std::vector<std::vector<float>> picked_proposals;

	float* data = (float*)outputs[0].data;

	const int dimensions = class_name.size() + 5 + 32;
	const int rows = 25200;
	for (int i = 0; i < rows; ++i) {
		float confidence = data[4];
		if (confidence >= CONFIDENCE_THRESHOLD) {
			float* classes_scores = data + 5;
			cv::Mat scores(1, class_name.size(), CV_32FC1, classes_scores);
			cv::Point class_id;
			double max_class_score;
			cv::minMaxLoc(scores, 0, &max_class_score, 0, &class_id);
			if (max_class_score > SCORE_THRESHOLD) {
				float x = (data[0] - params[2]) / params[0];  
				float y = (data[1] - params[3]) / params[1]; 
				float w = data[2] / params[0];
				float h = data[3] / params[1];
				int left = std::max(int(x - 0.5 * w), 0);
				int top = std::max(int(y - 0.5 * h), 0);
				int width = int(w);
				int height = int(h);
				boxes.push_back(cv::Rect(left, top, width, height));
				confidences.push_back(confidence);
				class_ids.push_back(class_id.x);

				std::vector<float> temp_proto(data + class_name.size() + 5, data + dimensions);
				picked_proposals.push_back(temp_proto);
			}
		}
		data += dimensions;
	}

	std::vector<int> indices;
	cv::dnn::NMSBoxes(boxes, confidences, SCORE_THRESHOLD, NMS_THRESHOLD, indices);
	std::vector<OutputSeg> output;
	std::vector<std::vector<float>> temp_mask_proposals;
	cv::Rect holeImgRect(0, 0, img.cols, img.rows);
	for (int i = 0; i < indices.size(); ++i) {
		int idx = indices[i];
		cv::Rect box = boxes[idx];

		boxes_set.push_back(box);
    confidences_set.push_back(confidences[idx]);
    classes_id_set.push_back(class_ids[idx]);
    classes_set.push_back(class_name[class_ids[idx]]);
    
		OutputSeg result;
		result.id = class_ids[idx];
		result.confidence = confidences[idx];
		result.box = boxes[idx] & holeImgRect;
		temp_mask_proposals.push_back(picked_proposals[idx]);
		output.push_back(result);
	}

	MaskParams mask_params;
	mask_params.params = params;
	mask_params.srcImgShape = img.size();
	for (int i = 0; i < temp_mask_proposals.size(); ++i) {
		get_mask(cv::Mat(temp_mask_proposals[i]).t(), outputs[1], output[i], mask_params);
		masks_set.push_back(output[i].boxMask);
	}

	draw_result(img, output, class_name);

	return img;
}

cv::Mat NeuralNetSegmentator::process(cv::Mat &img) {
  std::vector<cv::Mat> detections;
  cv::Vec4d params;
  detections = pre_process(img, params);
  cv::Mat res = post_process(img, detections, NeuralNetSegmentator::classes, params);
  // Put efficiency information.
  // The function getPerfProfile returns the overall time for inference(t) and the timings for each of the layers(in layersTimes)
  std::vector<double> layersTimes;
  double freq = cv::getTickFrequency();
  NeuralNetSegmentator::inference_time = network.getPerfProfile(layersTimes) / freq;
  return res;
}

std::string NeuralNetSegmentator::get_info(void) {
  std::string str = "";
  for (int i = 0; i < classes_id_set.size(); i++) {
    str += classes_set[i];
    str += ": ";
    str += std::to_string(confidences_set[i]);
    str += "\n";
  }
  return str;
}

int main() {
    cv::VideoCapture source(0);
    const std::string model_path = "nn/yolov5n-seg.onnx";
    const std::string classes_path = "nn/coco.names";
    NeuralNetSegmentator segmentator(model_path, classes_path, 640, 640);
    cv::Mat frame; 
    while(cv::waitKey(1) < 1) {
        source >> frame;
        if (frame.empty()) {
            cv::waitKey();
            break;
        }
    cv::Mat img = segmentator.process(frame);
    std::vector<int> class_ids = segmentator.get_class_ids();
    std::vector<float> confidences = segmentator.get_confidences();
    std::vector<cv::Rect> boxes = segmentator.get_boxes();
    std::vector<std::string> classes = segmentator.get_classes();
    std::vector<cv::Mat> masks = segmentator.get_masks();
    
    std::cout << "class_ids: ";
    for (auto element : class_ids) {
        std::cout << element << " ";
    }
    std::cout << std::endl;
    std::cout << "classes: ";
    for (auto element : classes) {
        std::cout << element << " ";
    }
    std::cout << std::endl;
    std::cout << "confidences: ";
    for (auto element : confidences) {
        std::cout << element << " ";
    }
    std::cout << std::endl;
    std::cout << "inference time: " << segmentator.get_inference() << std::endl;
   
    std::cout << segmentator.get_info();
   
    cv::imshow("Output", img);
    }
    cv::waitKey(0);
    return 0;
}
