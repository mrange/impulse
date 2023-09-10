namespace Impulse2023.GlimGlam;

class TheScreen : Screen
{
  // The name of the screen as it appears in the selection
  public override string Name => "GlimGlam/MyScreen";

  public static float Fract(float v)
  {
    return (float)(v - Math.Floor(v));
  }

  // Clears the screen
  public static void Clear(Canvas canvas)
  {
    for (int y = 0; y < canvas.Height; ++y)
    {
      for (int x = 0; x < canvas.Width; ++x)
      {
        canvas.SetPixel(x, y, Color.DarkBlue);
      }
    }
  }

  // Let's maintain some state on the position and direction of the box
  int currX = 0;
  int dirX = 1;

  // The half width of the Box
  const int HalfWidth = 3;

  public override void Update(Canvas canvas, double time)
  {
    Clear(canvas);

    // Updates state
    currX += dirX;

    // Checks it falls within the screen, otherwise reverse direction
    if (currX + HalfWidth > canvas.Width - 1)
    {
      currX = canvas.Width - 1 - HalfWidth;
      dirX = -1;
    } 
    else if (currX < HalfWidth)
    {
      currX = HalfWidth;
      dirX = 1;
    }

    // Computes the bounce
    var ft = Fract((float)time);
    ft -= 0.5F;
    var h = canvas.Height*2.0F*(0.25-ft*ft);

    // Setup the center of the box
    var x = currX;
    var y = (int)(canvas.Height-HalfWidth-1-h);

    // Draw the 4 edges of the box with 1 loop!! Efficient!
    for (int i = -HalfWidth; i <= HalfWidth; ++i) {
      canvas.SetPixel(i+x, y-HalfWidth, Color.Yellow);
      canvas.SetPixel(i+x, y+HalfWidth, Color.Blue);
      canvas.SetPixel(x-HalfWidth, i+y, Color.Green);
      canvas.SetPixel(x+HalfWidth, i+y, Color.Red);
    }
  }
}

