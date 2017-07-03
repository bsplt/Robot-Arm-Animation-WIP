Curve curve;
InteractionManager g;

void setup()
{
  size(700, 700);
  surface.setResizable(true);

  g = new InteractionManager(this);
  g.setupGrid(1, 100);

  curve = new Curve(this, g);
  curve.addPoint(20,40);
  curve.addPoint(80,20);
  curve.addPoint(70,80);
  curve.addPoint(40,50);
  curve.addPoint(30,20);
}

void draw()
{
  background(#fafafa);
}