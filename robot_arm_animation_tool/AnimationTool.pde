public class AnimationTool
{
  Curve curve;
  ArrayList<BezierPoint> points;
  InteractionManager g;
  PApplet p;
  AnimationPlayhead ap;
  boolean playing = false;

  AnimationTool(PApplet p, InteractionManager g)
  {
    this.p = p;
    this.g = g;
    setupEvents(p);
    ap = new AnimationPlayhead();
    points = null;
  }

  void setupEvents(PApplet p)
  {
    p.registerMethod("draw", this);
    //p.registerMethod("keyEvent", this);
  }

  void setCurve(Curve curve)
  {
    this.curve = curve;
  }

  void draw()
  {
    updatePlayhead();
    drawPlayhead();
  }

  void updatePoints()
  {
    if (points == null)
      return;
    if (!points.equals(curve.getPoints()))
    {
      points = curve.getPoints();
    }
  }

  void startAnimation()
  {
   ap.setPoints(curve.getPoints().get(0), curve.getPoints().get(1));
   playing = true;
  }

  void updatePlayhead()
  {
    
  }


  void drawPlayhead() {
    if (ap.getPos() != null && playing)
    {
      DisplayManager d = g.getDisplayManager();
      noStroke();
      fill(#FF6D00);
      d.ellipse(ap.getPos().x, ap.getPos().y, 2);
    }
  }
}

class AnimationPlayhead
{
  float t, len, speed;
  int deltaTime, lastTimestamp;
  BezierPoint[] points;

  AnimationPlayhead()
  {
    points = null;
    t = 0.5;
  }

  void setPoints(BezierPoint point1, BezierPoint point2)
  {
    points = new BezierPoint[2];
    points[0] = point1;
    points[1] = point2;
    t = t % 1;
  }

  PVector getPos()
  {
    if (points != null)
    {
      // https://stackoverflow.com/a/32841764
      float x = (1 - t) * (1 - t) * (1 - t) * points[0].getPos(0).x + 3 * (1 - t) * (1 - t ) * t * points[0].getPos(2).x + 3 * (1 - t) * t * t * points[1].getPos(1).x + t * t * t * points[1].getPos(0).x;
      float y = (1 - t) * (1 - t) * (1 - t) * points[0].getPos(0).y + 3 * (1 - t) * (1 - t ) * t * points[0].getPos(2).y + 3 * (1 - t) * t * t * points[1].getPos(1).y + t * t * t * points[1].getPos(0).y;
      return new PVector(x, y);
    } else {
      return null;
    }
  }
  
  // http://www.carlosicaza.com/2012/08/12/an-more-efficient-way-of-calculating-the-length-of-a-bezier-curve-part-ii/

  void calculateDeltaTime()
  {
    int thisTimestamp = millis();
    deltaTime = thisTimestamp - lastTimestamp;
    lastTimestamp = thisTimestamp;
  }
}