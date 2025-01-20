#include "Wire.h"

#include "I2Cdev.h"
#include "ADXL345.h"
#include "HMC5883L.h"
#include "ITG3200.h"
#include "MadgwickAHRS.h"
#include "MahonyAHRS.h"

#include <math.h>

ADXL345 accel;
ITG3200 gyro;
HMC5883L mag;
Madgwick filter;
Mahony filter1;

int16_t mx_raw, my_raw, mz_raw;
int16_t gx_raw, gy_raw, gz_raw;
int16_t ax_raw, ay_raw, az_raw;

void setup() {
    Wire.begin();
    Serial.begin(115200);
    
    Serial.println("Initializing I2C devices...");
    
    accel.initialize();
    Serial.println("Testing device connections...");
    Serial.println(accel.testConnection() ? "ADXL345 connection successful" : "ADXL345 connection failed");
    
    gyro.initialize();
    
    mag.initialize();
    Serial.println("Testing device connections...");
    Serial.println(mag.testConnection() ? "HMC5883L connection successful" : "HMC5883L connection failed");
    accel.setOffsetX(-6); // -round((279 - 256)/4)
    accel.setOffsetY(-1); // -round((258 - 256)/4)
    accel.setOffsetZ(-10); // -round((296 - 256)/4)
    accel.setRange(ADXL345_RANGE_2G);

    filter.begin(10);
    filter1.begin(10);
}

float phi = 0;
float theta = 0;
float psi = 0;

void loop() {
    accel.getAcceleration(&ax_raw, &ay_raw, &az_raw);
    gyro.getRotation(&gx_raw, &gy_raw, &gz_raw);
    mag.getHeading(&mx_raw, &my_raw, &mz_raw);

    float ax = (ax_raw * 1.0) / 256.0;
    float ay = (ay_raw * 1.0) / 256.0;
    float az = (az_raw * 1.0) / 256.0;

    float gx = ((gx_raw * 14.375) / 2000.0); // deg/sec
    float gy = ((gy_raw * 14.375) / 2000.0); // deg/sec
    float gz = ((gz_raw * 14.375) / 2000.0); // deg/sec

    float mx = mx_raw / 4096.0;
    float my = my_raw / 4096.0;
    float mz = mz_raw / 4096.0;

    #if 1
    filter.update(gx, gy, gz, ax, ay, az, mx, my, mz);
    filter1.update(gx, gy, gz, ax, ay, az, mx, my, mz);
    #else
    filter.updateIMU(gx, gy, gz, ax, ay, az);
    filter1.updateIMU(gx, gy, gz, ax, ay, az);
    #endif
    
    #if 1
    phi = filter.getPitchRadians();
    theta = filter.getRollRadians();
    psi = filter.getYawRadians();
    #endif

    #if 0
    phi = filter1.getPitchRadians();
    theta = filter1.getRollRadians();
    psi = filter1.getYawRadians();
    #endif

    #if 1
    Serial.print("phi:"); Serial.print(phi * 180 / PI); Serial.print(",");
    Serial.print("theta:"); Serial.print(theta * 180 / PI); Serial.print(",");
    Serial.print("psi:"); Serial.print(psi * 180 / PI); Serial.println();
    #endif
    
    delay(10);
}
