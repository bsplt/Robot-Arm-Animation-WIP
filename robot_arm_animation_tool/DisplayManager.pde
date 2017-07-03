class DisplayManager
{
  PApplet p5;
  float aspectRatio;
  float scale;

  DisplayManager(PApplet p5)
  {
    this.p5 = p5;
    aspectRatio = 1;
    scale = 1;
  }

  void setAspectRatio(float aspectRatio)
  {
    this.aspectRatio = aspectRatio;
  }

  void setGridScale(float scale)
  {
    this.scale = scale;
  }

  float s(float convertToPixels)
    // converts distances to screen pixels;
  {
    if ((float) width / height <= aspectRatio)
    {
      return convertToPixels / scale * width / aspectRatio;
    } else
    {
      return convertToPixels / scale * height;
    }
  }

  float w(float convertToPixels)
    // converts horizontal coordinates to screen pixels
  {

    if ((float) width / height <= aspectRatio)
    {
      return convertToPixels / scale * width;
    } else
    {
      return convertToPixels / scale * height * aspectRatio;
    }
  }

  float h(float convertToPixels)
    // converts vertical coordinates to screen pixels
  {

    if ((float) width / height >= aspectRatio)
    {
      return convertToPixels / scale * height;
    } else
    {
      return convertToPixels / scale * width / aspectRatio;
    }
  }

  boolean widerThanAspectRatio()
  {
    if ((float) width / height > aspectRatio)
    {
      return true;
    }
    return false;
  }

  float getScaleHorizontal()
  {
    return scale;
  }

  float getScaleVertical()
  {
    return scale * aspectRatio;
  }

  float x(float convertToPixels)
    // adds an offset to w() to keep the screen space centered
  {
    float val = w(convertToPixels);
    if (widerThanAspectRatio())
    {
      val += (width - height * aspectRatio) / 2;
    }
    return val;
  }

  float y(float convertToPixels)
    // adds an offset to h() to keep the screen space centered
  {
    float val = h(convertToPixels);
    if (!widerThanAspectRatio())
    {
      val += + (height - width / aspectRatio) / 2;
    }
    return val;
  }

  PVector constrainToAcitveArea(PVector pos)
  {
    if (pos.x < 0)
      pos.x = 0;
    if (pos.x > scale)
      pos.x = scale;
    if (pos.y < 0)
      pos.y = 0;
    if (pos.y > scale)
      pos.y = scale;
    return pos;
  }

  void line(float a, float b, float c, float d)
  {
    p5.line(x(a), y(b), x(c), y(d));
  }

  void rect(float a, float b, float c, float d)
  {
    p5.rect(x(a), y(b), w(c), h(d));
  }

  void ellipse(float a, float b, float c)
  {
    p5.ellipse(x(a), y(b), s(c), s(c));
  }

  void ellipse(float a, float b, float c, float d)
  {
    p5.ellipse(x(a), y(b), w(c), h(d));
  }

  void quad(float a, float b, float c, float d, float e, float f, float g, float h)
  {
    p5.quad(x(a), y(b), x(c), y(d), x(e), y(f), x(g), y(h));
  }

  void arc(float a, float b, float c, float d, float e, float f)
  {
    arc(a, b, c, d, e, f, OPEN);
  }

  void arc(float a, float b, float c, float d, float e, float f, int mode)
  {
    p5.arc(x(a), y(b), w(c), h(d), e, f, mode);
  }

  void arc(float a, float b, float c, float d, float e)
  {
    p5.arc(x(a), y(b), s(c), s(c), d, e, OPEN);
  }

  void triangle(float a, float b, float c, float d, float e, float f)
  {
    p5.triangle(x(a), y(b), x(c), y(d), x(e), y(f));
  }

  void bezier(float a, float b, float c, float d, float e, float f, float g, float h)
  {
    p5.bezier(x(a), y(b), x(c), y(d), x(e), y(f), x(g), y(h));
  }

  float getScreenPixelToGridHorizontal(float convertToGrid)
  {
    if ((float) width / height <= aspectRatio)
    {
      return (float) convertToGrid / width * scale;
    } else
    {
      float offset = (float) (width - height) / 2;
      return map(convertToGrid, offset, width - offset, 0, scale);
    }
  }

  float getScreenPixelToGridVertical(float convertToGrid)
  {
    if ((float) width / height >= aspectRatio)
    {
      return (float) convertToGrid / height * scale;
    } else
    {
      float offset = (float) (height - width) / 2;
      return map(convertToGrid, offset, height - offset, 0, scale);
    }
  }

  float getMouseX()
  {
    return getScreenPixelToGridHorizontal(mouseX);
  }

  float getMouseY()
  {
    return getScreenPixelToGridVertical(mouseY);
  }

  float getPMouseX()
  {
    return getScreenPixelToGridHorizontal(pmouseX);
  }

  float getPMouseY()
  {
    return getScreenPixelToGridVertical(pmouseY);
  }

  float getDeltaMouseX()
  {
    return getScreenPixelToGridHorizontal(mouseX - pmouseX);
  }
}