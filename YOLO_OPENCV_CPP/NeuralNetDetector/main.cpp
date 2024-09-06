#include <opencv2/opencv.hpp>
#include <iostream>
#include <fstream>
#include <cerrno>

/** Параметры обработки */
static const float SCORE_THRESHOLD      = 0.50;
static const float NMS_THRESHOLD        = 0.45;
static const float CONFIDENCE_THRESHOLD = 0.45;

/** Параметры шрифтов */
static const float FONT_SCALE = 0.7;
static const int   THICKNESS  = 1;

/** Цветовые константы */
static cv::Scalar BLACK  = cv::Scalar(0,   0,   0);
static cv::Scalar YELLOW = cv::Scalar(0, 255, 255);
static cv::Scalar RED    = cv::Scalar(0,   0, 255);
static cv::Scalar GREEN  = cv::Scalar(0, 255,   0);

/** Класс детектора */
class NeuralNetDetector {
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
    /** Время обработки */
    float inference_time;
    /** Получить строковые значения классов */
    error_t read_classes(const std::string file_path);
    /** Инициализация нейросети */
    error_t init_network(const std::string model_path, 
                         const std::string classes_path);
    /** Отрисовка метки */
    void draw_label(cv::Mat& img, std::string label, int left, int top);
    /** Предобработка результатов */
    std::vector<cv::Mat> pre_process(cv::Mat &img);
    /** Постобработка результатов */
    cv::Mat post_process(cv::Mat &img, std::vector<cv::Mat> &outputs, 
                         const std::vector<std::string> &class_name);
  public:
    NeuralNetDetector(const std::string model, const std::string classes, 
                      int width, int height);
    std::vector<float> get_confidences(void) { return confidences_set; }
    std::vector<cv::Rect> get_boxes(void) { return boxes_set; }
    std::vector<int> get_class_ids(void) { return classes_id_set; }
    std::vector<std::string> get_classes(void) { return classes_set; }
    float get_inference(void) { return inference_time; }
    std::string get_info(void);
    cv::Mat process(cv::Mat &img);
};

NeuralNetDetector::NeuralNetDetector(const std::string model, const std::string classes, 
                                     int width = 640, int height = 640) {
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

error_t NeuralNetDetector::read_classes(const std::string file_path) {
  std::ifstream classes_file(file_path);
  std::string line;

  if (!classes_file) {
    std::cerr << "Failed to open classes names!\n";
    return ENOENT;
  }
  while (std::getline(classes_file, line)) {
    classes.push_back(line);
  }
  classes_file.close();

  return 0;
}

error_t NeuralNetDetector::init_network(const std::string model_path, 
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

// Draw the predicted bounding box.
void NeuralNetDetector::draw_label(cv::Mat& img, std::string label, int left, int top) {
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

std::vector<cv::Mat> NeuralNetDetector::pre_process(cv::Mat &img) {
  // Convert to blob.
  cv::Mat blob;
  cv::dnn::blobFromImage(img, blob, 1.0 / 255.0, cv::Size(input_width, input_height), 
                         cv::Scalar(), true, false);
  network.setInput(blob);
  // Forward propagate.
  std::vector<cv::Mat> outputs;
  network.forward(outputs, network.getUnconnectedOutLayersNames());
  return outputs;
}

cv::Mat NeuralNetDetector::post_process(cv::Mat &img, std::vector<cv::Mat> &outputs, 
                                        const std::vector<std::string> &class_name) {
  // Initialize vectors to hold respective outputs while unwrapping detections.
  cv::Mat ret = img.clone(); // тормозит на 0.1 сек
  classes_id_set.clear();
  confidences_set.clear();
  boxes_set.clear();
  classes_set.clear();
  std::vector<int> class_ids;
  std::vector<float> confidences;
  std::vector<cv::Rect> boxes; 

  // Resizing factor.
  float x_factor = img.cols / (float)input_width;
  float y_factor = img.rows / (float)input_height;

  int dimensions = outputs[0].size[2];
  int rows = outputs[0].size[1];
  bool yolov8 = false;
  if (dimensions > rows) {
    yolov8 = true;
    rows = outputs[0].size[2];
    dimensions = outputs[0].size[1];
    outputs[0] = outputs[0].reshape(1, dimensions);
    cv::transpose(outputs[0], outputs[0]);
  }
  float *data = (float *)outputs[0].data;

  // Iterate through detections.
  for (int i = 0; i < rows; ++i) {
    if (yolov8) {
      float *classes_scores = data + 4;
      cv::Mat scores(1, class_name.size(), CV_32FC1, classes_scores);
      cv::Point class_id;
      double max_class_score;
      cv::minMaxLoc(scores, 0, &max_class_score, 0, &class_id);
      if (max_class_score > SCORE_THRESHOLD) {
        confidences.push_back(max_class_score);
        class_ids.push_back(class_id.x);
        float cx = data[0];
        float cy = data[1];
        float w = data[2];
        float h = data[3];
        int left = int((cx - 0.5 * w) * x_factor);
        int top = int((cy - 0.5 * h) * y_factor);
        int width = int(w * x_factor);
        int height = int(h * y_factor);
        boxes.push_back(cv::Rect(left, top, width, height));
      }
    } else {
      float confidence = data[4];
      // Discard bad detections and continue.
      if (confidence >= CONFIDENCE_THRESHOLD) {
        float * classes_scores = data + 5;
        // Create a 1x85 Mat and store class scores of 80 classes.
        cv::Mat scores(1, class_name.size(), CV_32FC1, classes_scores);
        // Perform minMaxLoc and acquire index of best class score.
        cv::Point class_id;
        double max_class_score;
        cv::minMaxLoc(scores, 0, &max_class_score, 0, &class_id);
        // Continue if the class score is above the threshold.
        if (max_class_score > SCORE_THRESHOLD) {
          // Store class ID and confidence in the pre-defined respective vectors.
          confidences.push_back(confidence);
          class_ids.push_back(class_id.x);
          // Center.
          float cx = data[0];
          float cy = data[1];
          // Box dimension.
          float w = data[2];
          float h = data[3];
          // Bounding box coordinates.
          int left = int((cx - 0.5 * w) * x_factor);
          int top = int((cy - 0.5 * h) * y_factor);
          int width = int(w * x_factor);
          int height = int(h * y_factor);
          // Store good detections in the boxes vector.
          boxes.push_back(cv::Rect(left, top, width, height));
        }
      }
    }
    // Jump to the next column.
    data += dimensions;
  }

  // Perform Non Maximum Suppression and draw predictions.
  std::vector<int> indices;
  cv::dnn::NMSBoxes(boxes, confidences, SCORE_THRESHOLD, NMS_THRESHOLD, indices);
  for (int i = 0; i < indices.size(); i++) {
    int idx = indices[i];
    cv::Rect box = boxes[idx];
    
    boxes_set.push_back(box);
    confidences_set.push_back(confidences[idx]);
    classes_id_set.push_back(class_ids[idx]);
    classes_set.push_back(class_name[class_ids[idx]]);
    
    int left = box.x;
    int top = box.y;
    int width = box.width;
    int height = box.height;
    // Draw bounding box.
    cv::rectangle(ret, cv::Point(left, top), cv::Point(left + width, top + height), GREEN, 3*THICKNESS);
    // Get the label for the class name and its confidence.
    std::string label = cv::format("%.2f", confidences[idx]);
    label = class_name[class_ids[idx]] + ": " + label;
    // Draw class labels.
    draw_label(ret, label, left, top);
  }
  return ret;
}

cv::Mat NeuralNetDetector::process(cv::Mat &img) {
  std::vector<cv::Mat> detections;
  detections = pre_process(img);
  cv::Mat res = post_process(img, detections, NeuralNetDetector::classes);
  // Put efficiency information.
  // The function getPerfProfile returns the overall time for inference(t) and the timings for each of the layers(in layersTimes)
  std::vector<double> layersTimes;
  double freq = cv::getTickFrequency();
  NeuralNetDetector::inference_time = network.getPerfProfile(layersTimes) / freq;
  return res;
}

std::string NeuralNetDetector::get_info(void) {
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
    const std::string model_path = "nn/yolov8s.onnx";
    const std::string classes_path = "nn/coco.names";
    NeuralNetDetector detector(model_path, classes_path, 640, 640);
    cv::Mat frame; 
    while(cv::waitKey(1) < 1) {
        source >> frame;
        if (frame.empty()) {
            cv::waitKey();
            break;
        }
    cv::Mat img = detector.process(frame);
    std::vector<int> class_ids = detector.get_class_ids();
    std::vector<float> confidences = detector.get_confidences();
    std::vector<cv::Rect> boxes = detector.get_boxes();
    std::vector<std::string> classes = detector.get_classes();
    
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
    std::cout << "inference time: " << detector.get_inference() << std::endl;
   
    std::cout << detector.get_info();
   
    cv::imshow("Output", img);
    }
    cv::waitKey(0);
    return 0;
}
