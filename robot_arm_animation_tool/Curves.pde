public class Curve
{
  ArrayList<BezierPoint> bezierPoints;
  PApplet p;
  InteractionManager g;
  BezierPoint lastActive;
  BezierPoint previouslastActive;
  boolean focusMode = false;
  int focusOnPoint = -1;

  Curve(PApplet p, InteractionManager g)
  {
    setupEvents(p);
    this.p = p;
    this.g = g;
    bezierPoints = new ArrayList<BezierPoint> ();
  }

  void setupEvents(PApplet p)
  {
    p.registerMethod("draw", this);
    p.registerMethod("keyEvent", this);
  }

  void draw()
  {
    drawCurve();
    drawLastActive();
    focus();
  }

  public void keyEvent(KeyEvent e)
  {
    if (e.getAction() == KeyEvent.RELEASE)
    {
      switch(e.getKey())
      {
      case 'a':
        addKey();
        break;
      case 'd':
        deleteKey();
        break;
      case 's':
        unselectKey();
        break;
      case 'f':
        toggleFocusMode();
        break;
      }
    }
  }

  void deleteKey()
  {
    if (lastActive != null)
    {
      int deletedIndex = bezierPoints.indexOf(lastActive);
      lastActive.destroy();
      bezierPoints.remove(lastActive);
      if (deletedIndex > 0)
      {
        lastActive = bezierPoints.get(deletedIndex - 1);
      } else if (bezierPoints.size() > 0)
      {
        lastActive = bezierPoints.get(deletedIndex);
      } else {
        lastActive = null;
      }
    }
  }

  void addKey()
  {
    DisplayManager d = g.getDisplayManager();
    PVector pos = new PVector(d.getMouseX(), d.getMouseY());
    pos = d.constrainToAcitveArea(pos);

    if (lastActive != null && bezierPoints.size() > 1)
    {
      int addNewAfter = bezierPoints.indexOf(lastActive);
      addPoint(pos.x, pos.y, addNewAfter + 1);
      lastActive = bezierPoints.get(addNewAfter + 1);
    } else
    {
      addPoint(pos.x, pos.y);
      lastActive = bezierPoints.get(bezierPoints.size() - 1);
    }
  }

  void unselectKey()
  {
    lastActive = null;
  }

  BezierPoint getActivePoint()
  {
    for (int i = 0; i < bezierPoints.size(); i++)
    {
      if (bezierPoints.get(i).isActive())
      {
        return bezierPoints.get(i);
      }
    }
    return null;
  }

  void toggleFocusMode()
  {
    focusMode = !focusMode;
    focusOnPoint = -1;
    focus();
  }

  void focus()
  {
    int index = bezierPoints.indexOf(lastActive);
    if (index != focusOnPoint) {
      if (focusMode && lastActive != null)
      {
        focusOnPoint = index;
        for (int i = 0; i < bezierPoints.size(); i++)
        {
          BezierPoint point = bezierPoints.get(i);
          point.showPoints(0, false);
          point.showPoints(1, false);
          point.showPoints(2, false);

          if (i == index - 2)
          {
            point.showPoints(0, true);
            point.showPoints(2, true);
          } else if (i == index || i == index - 1 || i == index + 1) {
            point.showPoints(0, true);
            point.showPoints(1, true);
            point.showPoints(2, true);
          } else if (i == index + 2) {
            point.showPoints(0, true);
            point.showPoints(1, true);
          }
        }
      } else {
        focusOnPoint = index;
        for (int i = 0; i < bezierPoints.size(); i++)
        {
          BezierPoint point = bezierPoints.get(i);
          point.showPoints(0, true);
          point.showPoints(1, true);
          point.showPoints(2, true);
        }
      }
    }
  }

  void drawCurve()
  {
    if (bezierPoints.size() >= 2)
    {
      DisplayManager d = g.getDisplayManager();
      noFill();
      stroke(#311B92);
      for (int i = 0; i < bezierPoints.size() - 1; i++)
      {
        BezierPoint point1 = bezierPoints.get(i);
        BezierPoint point2 = bezierPoints.get(i + 1);
        d.bezier(point1.getPos(0).x, point1.getPos(0).y, point1.getPos(2).x, point1.getPos(2).y, point2.getPos(1).x, point2.getPos(1).y, point2.getPos(0).x, point2.getPos(0).y);
      }
    }
  }

  void drawLastActive()
  {
    BezierPoint active = getActivePoint();
    if (active != null)
      lastActive = active;

    if (lastActive != null)
    {
      DisplayManager d = g.getDisplayManager();
      PVector pos = lastActive.getPos(0);
      noFill();
      stroke(#9575CD);
      d.ellipse(pos.x, pos.y, 2);
    }
  }

  void addPoint(float x, float y)
  {
    bezierPoints.add(new BezierPoint(p, g, x, y));
  }

  void addPoint(float x, float y, int index)
  {
    bezierPoints.add(index, new BezierPoint(p, g, x, y));
  }

  ArrayList<BezierPoint> getPoints()
  {
    return bezierPoints;
  }
}

public class BezierPoint
{
  InteractionElementAbstract anchor, control1, control2;
  PVector anchorOffset;
  PApplet p;

  BezierPoint(PApplet p, InteractionManager g, float x, float y)
  {
    setupBezier(x, y);
    setupEvents(p);
  }

  void setupBezier(float x, float y)
  {
    anchor = g.registerDraggable(x, y, .5);
    anchorOffset = anchor.getPos().copy();
    control1 = g.registerDraggable(x - 2, y, .5);
    control1.setMoveConstrain(false);
    control1.setColors(#757575, #bdbdbd);
    control2 = g.registerDraggable(x + 2, y, .5);
    control2.setMoveConstrain(false);
    control2.setColors(#757575, #bdbdbd);
  }

  void destroy()
  {
    g.unregisterInteractionElement(anchor);
    g.unregisterInteractionElement(control1);
    g.unregisterInteractionElement(control2);
    p.unregisterMethod("draw", this);
  }

  void setupEvents(PApplet p)
  {
    this.p = p;
    p.registerMethod("draw", this);
  }

  void draw()
  {
    pointMovement();
    drawConnections();
  }

  void drawConnections()
  {
    noFill();
    stroke(#424242);
    DisplayManager d = g.getDisplayManager();
    if (control1.getVisibility())
      d.line(control1.getPos().x, control1.getPos().y, anchor.getPos().x, anchor.getPos().y);
    if (control2.getVisibility())
      d.line(control2.getPos().x, control2.getPos().y, anchor.getPos().x, anchor.getPos().y);
  }

  void pointMovement()
  {
    if (anchor.isActive())
    {
      moveWithAnchor(control1);
      moveWithAnchor(control2);
      anchorOffset = anchor.getPos().copy();
    }
    if (control1.isActive())
      rotateAroundAnchor(control1, control2);
    if (control2.isActive())
      rotateAroundAnchor(control2, control1);
  }

  void moveWithAnchor(InteractionElementAbstract element)
  {
    element.getPos().sub(anchorOffset);
    element.getPos().add(anchor.getPos());
  }

  void rotateAroundAnchor(InteractionElementAbstract element1, InteractionElementAbstract element2)
  {
    element2.getPos().sub(anchor.getPos());
    float angle = PVector.sub(element1.getPos(), anchor.getPos()).heading() + PI;
    float mag = element2.getPos().mag();
    element2.getPos().set(cos(angle) * mag, sin(angle) * mag);
    element2.getPos().add(anchor.getPos());
  }

  PVector getPos(int index)
  {
    if (index == 0)
      return anchor.getPos();
    if (index == 1)
      return control1.getPos();
    if (index == 2)
      return control2.getPos();
    return null;
  }

  boolean isActive()
  {
    if (anchor.isActive() || control1.isActive() || control2.isActive())
      return true;
    return false;
  }

  void showPoints(int index, boolean show)
  {
    if (index == 0)
      anchor.setVisibility(show);
    if (index == 1)
      control1.setVisibility(show);
    if (index == 2)
      control2.setVisibility(show);
  }
}