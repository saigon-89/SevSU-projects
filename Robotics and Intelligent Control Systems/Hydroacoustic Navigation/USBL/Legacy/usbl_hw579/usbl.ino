#include "Wire.h"

#include "I2Cdev.h"
#include "ADXL345.h"
#include "HMC5883L.h"
#include "ITG3200.h"

#include <math.h>

ADXL345 accel;
ITG3200 gyro;
HMC5883L mag;

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
    mag.setGain(HMC5883L_GAIN_1370);
    Serial.println("Testing device connections...");
    Serial.println(mag.testConnection() ? "HMC5883L connection successful" : "HMC5883L connection failed");
    accel.setOffsetX(-6); // -round((279 - 256)/4)
    accel.setOffsetY(-1); // -round((258 - 256)/4)
    accel.setOffsetZ(-10); // -round((296 - 256)/4)
    accel.setRange(ADXL345_RANGE_2G);
}

float phi = 0;
float theta = 0;
float psi = 0;

void loop() {
    accel.getAcceleration(&ax_raw, &ay_raw, &az_raw);
    gyro.getRotation(&gx_raw, &gy_raw, &gz_raw);
    mag.getHeading(&mx_raw, &my_raw, &mz_raw);

    float nx = (ax_raw * 1.0) / 256.0;
    float ny = (ay_raw * 1.0) / 256.0;
    float nz = (az_raw * 1.0) / 256.0;

    float ax = atan(ny / sqrt(sq(nx) + sq(nz)));
    float ay = atan(-1 * nx / sqrt(sq(ny) + sq(nz)));
    float az = atan2(ay, ax);

    float gx = ((gx_raw * 14.375) / 2000.0) * (PI / 180.0);
    float gy = ((gy_raw * 14.375) / 2000.0) * (PI / 180.0);
    float gz = ((gz_raw * 14.375) / 2000.0) * (PI / 180.0);

    float mx = mx_raw / 4096.0;
    float my = my_raw / 4096.0;
    float mz = mz_raw / 4096.0;

    phi = 0.98 * (phi + gx * 0.01) + 0.02 * ax;
    theta = 0.98 * (theta + gy * 0.01) + 0.02 * ay;
    psi = 0.98 * (psi + gz * 0.01) + 0.02 * az;
    
    psi = atan2(my, mx);
    // Correct for when signs are reversed.
    if (psi < 0) {
      psi += 2*PI;
    }
    // Check for wrap due to addition of declination.
    if (psi > 2*PI) {
      psi -= 2*PI;
    }
    
    #if 0
    Serial.print("ax:"); Serial.print(nx); Serial.print(",");
    Serial.print("ay:"); Serial.print(ny); Serial.print(",");
    Serial.print("az:"); Serial.print(nz); Serial.println();
    #endif

    #if 1
    Serial.print("phi:"); Serial.print(phi * 180 / PI); Serial.print(",");
    Serial.print("theta:"); Serial.print(theta * 180 / PI); Serial.print(",");
    Serial.print("psi:"); Serial.print(psi * 180 / PI); Serial.println();
    #endif

    #if 0
    Serial.print("ax:"); Serial.print(mx_raw); Serial.print(",");
    Serial.print("ay:"); Serial.print(my_raw); Serial.print(",");
    Serial.print("az:"); Serial.print(mz_raw); Serial.println();
    #endif
    
    delay(10);
}
