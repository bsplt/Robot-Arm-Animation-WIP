import java.io.Serializable;
import java.io.FileOutputStream;
import java.io.ObjectOutputStream;
import java.io.FileInputStream;
import java.io.ObjectInputStream;
import java.io.EOFException;

Position position;

void setup()
{
  size(800, 800);
  position = Position.load();
}


void draw()
{
  background(#fafafa);
  position.show();
}

void mouseReleased()
{
  position.set(mouseX, mouseY);
  position.save();
}

class Position implements Serializable
{
  int x, y;

  Position()
  {
    x = 400;
    y = 400;
  }

  void show()
  {
    noStroke();
    fill(#0091EA);
    ellipse(x, y, 20, 20);
  }

  void set(int x, int y)
  {
    this.x = x;
    this.y = y;
  }

  void save()
  {
    try
    {
      FileOutputStream file = new FileOutputStream(sketchPath() + "/save.dat");
      ObjectOutputStream output = new ObjectOutputStream(file);
      output.writeObject(this); 
      output.close();
    }
    catch (Exception e)
    {
      e.printStackTrace();
      println(e.getMessage());
    }
  }

  static public Position load()
  {
    Position p = null;
    try
    {
      FileInputStream file = new FileInputStream(sketchPath() + "/save.dat");
      ObjectInputStream input = new ObjectInputStream(file);
      Object aux = input.readObject();
      input.close();
      if (aux instanceof Position)
      {
        p = (Position) aux;
      }
    }
    catch (EOFException e1)
    {
      System.out.println ("Fin de fichero");
    }
    catch (Exception e2)
    {
      e2.printStackTrace();
    }
    return p;
  }
}