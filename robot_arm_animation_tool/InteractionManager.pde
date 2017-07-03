public class InteractionManager
{
  DisplayManager d;
  ArrayList<InteractionElementAbstract> interactionElements;
  PApplet p;

  InteractionManager(PApplet p)
  {
    d = new DisplayManager(p);
    this.p = p;
    interactionElements = new ArrayList<InteractionElementAbstract>();
    setupGrid(1, 100);
    setupEvents();
  }

  DisplayManager getDisplayManager()
  {
    return d;
  }

  DisplayManager d()
  {
    return getDisplayManager();
  }

  void setupGrid(float aspectRatio, float resolution)
  {
    d.setAspectRatio(aspectRatio);
    d.setGridScale(resolution);
  }

  void setupEvents()
  {
    p.registerMethod("mouseEvent", this);
    p.registerMethod("draw", this);
  }

  public void mouseEvent(MouseEvent e)
  {
    switch(e.getAction())
    {
    case MouseEvent.PRESS:
      mousePressed();
      break;
    case MouseEvent.RELEASE:
      mouseReleased();
      break;
    case MouseEvent.DRAG:
      //mouseDragged();
      break;
    }
  }

  void unregisterInteractionElement(InteractionElementAbstract element)
  {
    interactionElements.remove(element);
  }

  InteractionElementAbstract registerDraggable(float x, float y, float size)
  {
    InteractionElementDraggable element = new InteractionElementDraggable(getDisplayManager(), x, y);
    element.setRange(size);
    interactionElements.add(element);
    return element;
  }

  void draw()
  {
    holdInteractionElements();
    updateInteractionElements();
  }

  void mousePressed()
  {
    activateInteractionElements();
  }

  void mouseReleased()
  {
    deactivateInteractionElements();
  }

  void holdInteractionElements()
  {
    cursor(ARROW);
    for (int i = 0; i < interactionElements.size(); i++)
    {
      InteractionElementAbstract element = interactionElements.get(i);
      if (element.isActive())
      {
        element.interact();
      }
    }
  }

  void updateInteractionElements()
  {
    for (int i = 0; i < interactionElements.size(); i++)
    {
      InteractionElementAbstract element = interactionElements.get(i);
      element.update();
    }
  }

  void activateInteractionElements()
  {
    for (int i = interactionElements.size() - 1; i >= 0; i--)
    {
      InteractionElementAbstract element = interactionElements.get(i);
      if (element.checkMouseOver())
      {
        element.setActive(true);
        moveElementUp(i);
        break;
      }
    }
  }

  void moveElementUp(int index) 
  {
    // higher elements in the list get drawn later i.e. they visually appear to be on top
    InteractionElementAbstract moveThisUp = interactionElements.get(index);
    int newIndex = index;
    for (int i = index; i < interactionElements.size() - 1; i++)
    {
      interactionElements.set(i, interactionElements.get(i + 1));
      newIndex = i + 1;
    }
    interactionElements.set(newIndex, moveThisUp);
  }

  void deactivateInteractionElements()
  {
    for (int i = 0; i < interactionElements.size(); i++)
    {
      interactionElements.get(i).setActive(false);
    }
  }
}


// ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

abstract class InteractionElementAbstract
{
  PVector pos;
  int cursor = MOVE;
  boolean active = false;
  DisplayManager d;
  boolean moveConstrain = true;
  color colorNormal = 66;
  color colorActive = 97;
  boolean visible = true;

  InteractionElementAbstract(DisplayManager d, float x, float y)
  {
    this.d = d;
    initPos(x, y);
  }

  InteractionElementAbstract(DisplayManager d, float x, float y, int cursor)
  {
    this.d = d;
    this.cursor = cursor;
    initPos(x, y);
  }

  void setMoveConstrain(boolean moveConstrain)
  {
    this.moveConstrain = moveConstrain;
  }

  void setColors(color colorNormal, color colorActive)
  {
    this.colorNormal = colorNormal;
    this.colorActive = colorActive;
  }

  void setMovementConstraint(boolean moveConstrain)
  {
    this.moveConstrain = moveConstrain;
  }

  void update()
  {
    constrainMovement();
    getColors();
    show();
  }

  void constrainMovement()
  {
    if (moveConstrain) 
    {
      if (pos.x < 0)
        pos.x = 0;
      if (pos.y < 0)
        pos.y = 0;
      if (pos.x > d.getScaleHorizontal())
        pos.x = d.getScaleHorizontal();
      if (pos.y > d.getScaleVertical())
        pos.y = d.getScaleVertical();
    }
  }

  void getColors()
  {
    noStroke();
    fill(colorNormal);
    if (active)
      fill(colorActive);
  }

  void show()
  {
  }

  boolean checkMouseOver()
  {
    return false;
  }

  void interact() {
  };


  void initPos(float x, float y)
  {
    pos = new PVector(x, y);
  }

  PVector getPos()
  {
    return pos;
  }

  void setActive(boolean active)
  {
    this.active = active;
  }

  boolean isActive()
  {
    return active;
  }

  int getCursor()
  {
    return cursor;
  }

  void setVisibility(boolean visible)
  {
    this.visible = visible;
  }

  boolean getVisibility()
  {
    return visible;
  }
}

class InteractionElementDraggable extends InteractionElementAbstract
{
  float range = 5;
  PVector offset;

  InteractionElementDraggable(DisplayManager d, float x, float y)
  {
    super(d, x, y);
  }

  InteractionElementDraggable(DisplayManager d, float x, float y, int cursor)
  {
    super(d, x, y, cursor);
  }

  void setRange(float range)
  {
    this.range = range;
  }

  void show()
  {
    if (visible)
      d.ellipse(pos.x, pos.y, 2 * range);
  }

  void initPos(float x, float y)
  {
    pos = new PVector(x, y);
    offset = new PVector(0, 0);
  }

  boolean checkMouseOver()
  {
    if (dist(d.getMouseX(), d.getMouseY(), pos.x, pos.y) <= range && visible)
    {
      return true;
    }
    return false;
  }

  void interact() {
    setToMousePos();
    cursor(getCursor());
  }

  void setToMousePos()
  {
    pos.x = d.getMouseX() + offset.x;
    pos.y = d.getMouseY() + offset.y;
  }

  void setActive(boolean active)
  {
    this.active = active;
    setMouseOffset();
  }

  void setMouseOffset()
  {
    // helps to prevent errors with the mouse delta
    offset.x = pos.x - d.getMouseX();
    offset.y = pos.y - d.getMouseY();
  }
}

// TODOs:
// Buttons
// Fader