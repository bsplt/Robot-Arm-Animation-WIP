/*
Demonstrates the control of digital pins of an Arduino board running the
 StandardFirmata firmware.  Clicking the squares toggles the corresponding
 digital pin of the Arduino.  
 */

import processing.serial.*;
import cc.arduino.*;

Arduino arduino;
boolean forward = true;

void setup() {
  size(400, 400);
  frameRate(2400);

  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[0], 57600);

  for (int i = 2; i <= 5; i++)
    arduino.pinMode(i, Arduino.OUTPUT);

  background(#fafafa);
  textAlign(CENTER, CENTER);
  noStroke();
  fill(#212121);
  textSize(40);
  text("RUNNING", 200, 200);
}

void draw() {
  if (frameCount % 720 > 240)
  {
    arduino.digitalWrite(3, frameCount % 2 );
    arduino.digitalWrite(5, frameCount % 2 );
  }

  if (frameCount % 480 == 0) 
  {
    arduino.digitalWrite(2, forward ? 1 : 0);
    forward = !forward;
  }

  if (frameCount % 240 == 0) 
  {
    arduino.digitalWrite(4, forward ? 1 : 0);
    forward = !forward;
  }
}