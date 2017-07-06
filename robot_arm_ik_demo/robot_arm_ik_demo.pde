import cc.arduino.*;
import org.firmata.*;

RobotArm robotArm;
Arduino arduino;

void setup()
{
  size(700, 700);
  robotArm = new RobotArm(55, 240, 220);
  
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[0], 57600);
}

void draw()
{
  pushMatrix();
  translate(width / 3, height / 1.5);
  background(240);

  if (mousePressed)
  {
    robotArm.moveArmTowards(mouseX - width / 3, mouseY - height / 1.5);
    fill(#EA80FC);
    noStroke();
    ellipse(mouseX - width / 3, mouseY - height / 1.5, 10, 10);
  }

  robotArm.update();
  robotArm.show();

  popMatrix();
}

class Motor
{
  float stepAngle, lowerConstraint, upperConstraint;
  float rotationalPos = 0;
  int stepDirection = 1;

  Motor(float stepAngle_, boolean reverseDirection)
  {
    stepAngle = stepAngle_;
    if (reverseDirection)
    {
      stepDirection = -1;
    }
    lowerConstraint = -PI;
    upperConstraint = PI;
  }

  void show()
  {
    stroke(30);
    noFill();
    pushMatrix();
    rotate(rotationalPos);
    ellipse(50, 0, 4, 4);
    popMatrix();
  }

  void step(boolean forwardDirection)
  {
    int direction = forwardDirection ? 1 : -1;
    if (rotationalPos + stepAngle * stepDirection * direction > lowerConstraint && rotationalPos + stepAngle * stepDirection * direction < upperConstraint)
    { 
      rotationalPos += stepAngle * stepDirection * direction;
    }
  }

  void setRotation(float angle)
  {
    rotationalPos = angle;
  }

  float getRotation()
  {
    return rotationalPos;
  }

  float getMinimumStep()
  {
    return stepAngle;
  }

  void setConstraints(float lowerConstraint_, float upperConstraint_)
  {
    lowerConstraint = lowerConstraint_;
    upperConstraint = upperConstraint_;
  }
}

class RobotArm
{
  /* Schemactics of the arm:
   * In the origin, two stepper motors are each connected with either side A or B.
   * Through the parallelogrammatic structure the tip can be directed
   * to any point in reach just by adjusting the two motors.
   *
   *      D
   *  +---+---> tip
   *  |   |
   * C|   |B
   *  |   |
   *  +---x
   *    A
   *
   * x: origin
   * +: joint
   */

  Motor motorA, motorB; // left side and right side motors
  PVector segA, segB, segC, segD; // forming a parallelogram
  float relD; // relative length of the D Segment to the A segment

  RobotArm(float segALength, float segBLength, float segDLength)
  {
    segA = new PVector(0, segALength);
    segB = new PVector(0, segBLength);
    relD = segDLength / segALength;
    initMotors();
  }

  void initMotors()
  {
    motorA = new Motor(TWO_PI / 200, false);
    motorB = new Motor(TWO_PI / 200, false);
    motorA.setRotation(-PI * 0.75);
    motorB.setRotation(-HALF_PI / 2);
    motorA.setConstraints(-PI * 1.25, -HALF_PI);
    motorB.setConstraints(-2.8, 0);
  }

  void update()
  {
    segA.rotate(motorA.getRotation() - segA.heading());
    segB.rotate(motorB.getRotation() - segB.heading());
    segC = PVector.add(segA, segB);
    segD = PVector.add(segC, segA.copy().mult(-relD));
  }

  void show()
  {
    stroke(120);
    noFill();
    line(0, 0, segA.x, segA.y);
    line(0, 0, segB.x, segB.y);
    line(segA.x, segA.y, segC.x, segC.y);
    line(segC.x, segC.y, segD.x, segD.y);

    motorA.show();
    motorB.show();
  }

  void moveArmTowards(float posX, float posY)
  { 
    PVector reachTo = new PVector(posX, posY); 

    // Scale target point into the reach of the arm from the origin, if it is too fart or short:
    if (reachTo.mag() > segB.mag() + PVector.dist(segB, segD))
    {
      reachTo.mult((segB.mag() + PVector.dist(segB, segD)) / reachTo.mag() * 0.999);
    } else if (reachTo.mag() < segB.mag() - PVector.dist(segB, segD))
    {
      reachTo.mult((segB.mag() - PVector.dist(segB, segD)) / reachTo.mag() * 1.001);
    }

    /* Inverse Kinematics:
     To know how both motors need to be rotated, the program calcules two distinct angles.
     First, the angle of Segment B can be calculated by finding the position
     from which the target is exactly the distance of the outer limb of Segment D away.
     Mathematicaly the calculation finds the intersection between a circle of the radius of Seg B around the origin
     and a circle with the radius of the outer limb reach of Seg D around the target.
     I couldn't find better names for the variables. */

    // Distance from the Seg B circle to the center of both intersections and distance from center to intersection:
    float circleA = (sq(segB.mag()) - sq(PVector.dist(segB, segD)) + sq(reachTo.mag())) / (2 * reachTo.mag());
    float circleH = sqrt(sq(segB.mag()) - sq(circleA));

    // the center between both intersection points:
    float circlePx = circleA * reachTo.x / reachTo.mag();   
    float circlePy = circleA * reachTo.y / reachTo.mag(); 

    // left intersection point, the one we need to know, where Seg B has to roatate:
    float circleIx = circlePx + circleH * reachTo.y / reachTo.mag();
    float circleIy = circlePy - circleH * reachTo.x / reachTo.mag();

    /* The second angle (targetA) corresponds with the negative Vector
     between the intersection point and the target point: */
    PVector targetA = PVector.sub(reachTo, new PVector(circleIx, circleIy)).mult(-1);
    PVector targetB = new PVector(circleIx, circleIy);

    /* For motor A and B there is similar code following.
     The offset helps to deal with the problem of a rotation, that jumps from -Pi to Pi.
     So instead of making a full rotation in the wrong direction, offset aids the comparison.
     The next condition checks if the target is within the half of the step angle
     so that the arm doesn't osciallate around the target because it never can reach it. */

    float offsetA = targetA.heading() - PI > motorA.getRotation() ? -TWO_PI : 0;
    if (sq(targetA.heading() + offsetA - motorA.getRotation()) > sq(motorA.getMinimumStep() / 2))
    {
      motorA.step(targetA.heading() + offsetA < motorA.getRotation() ? false : true);
    }
    float offsetB = targetB.heading() - PI > motorB.getRotation() ? -TWO_PI : 0;
    if (sq(targetB.heading() + offsetB - motorB.getRotation()) > sq(motorB.getMinimumStep() / 2))
    {
      motorB.step(targetB.heading() + offsetB < motorB.getRotation() ? false : true);
    }
  }
}