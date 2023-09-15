#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <MadgwickAHRS.h>
#include <Wire.h>

Adafruit_MPU6050 mpu;
Madgwick filter;
unsigned long microsPerReading, microsPrevious;

void setup(void) {
  Serial.begin(115200);
  while (!Serial) {
    delay(10);
  }

  filter.begin(10); // TODO

  if (!mpu.begin()) {
    Serial.println("Failed to find MPU6050 chip");
    while (1) {
      delay(10);
    }
  }

  mpu.setAccelerometerRange(MPU6050_RANGE_2_G);
  mpu.setGyroRange(MPU6050_RANGE_250_DEG);

  // initialize variables to pace updates to correct rate
  microsPerReading = 10000;
  microsPrevious = micros();

  Serial.println("");
  delay(100);
}

void loop() {
  unsigned long microsNow;
  float phi, theta, psi;
  float ax, ay, az, gx, gy, gz;

  // check if it's time to read data and update the filter
  microsNow = micros();
  if (microsNow - microsPrevious >= microsPerReading) {
    /* Get new sensor events with the readings */
    sensors_event_t a, g, temp;
    mpu.getEvent(&a, &g, &temp);

    gx = g.gyro.x;
    gy = g.gyro.y;
    gz = g.gyro.z;
    ax = a.acceleration.x;
    ay = a.acceleration.y;
    az = a.acceleration.z;

    // update the filter, which computes orientation
    filter.updateIMU(gx, gy, gz, ax, ay, az);
    
    phi = filter.getRoll();
    theta = filter.getPitch();
    psi = filter.getYaw();
    
    /* Print out the values */
    Serial.print("phi:");
    Serial.print(phi);
    Serial.print(",");
    Serial.print("theta:");
    Serial.print(theta);
    Serial.print(",");
    Serial.print("psi:");
    Serial.print(psi);
    Serial.println("");

    // increment previous time, so we keep proper pace
    microsPrevious = microsPrevious + microsPerReading;
    
    //delay(10);
  }
}