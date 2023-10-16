namespace Impulse2023.Longshot.Lib;

using static System.Math;
using static System.Numerics.Vector3;

static class Utils
{
  // Draw Bresenham line
  public static void drawLine(double x0, double y0, double x1, double y1, int offsetX, int offsetY, Vector3 color, Canvas canvas)
  {
    var dx = Math.Abs(x1 - x0);
    var dy = Math.Abs(y1 - y0);
    var sx = x0 < x1 ? 1 : -1;
    var sy = y0 < y1 ? 1 : -1;
    var err = (dx > dy ? dx : -dy) / 2;
    while (true)
    {
      int screenX = Convert.ToInt32(x0) + canvas.Width / 2 + offsetX;
      int screenY = Convert.ToInt32(y0) + canvas.Height / 2 + offsetY;
      if (screenX < 0) screenX = 0;
      if (screenX > canvas.Width - 1) screenX = canvas.Width - 1;
      if (screenY < 0) screenY = 0;
      if (screenY > canvas.Height - 1) screenY = canvas.Height - 1;
      canvas.SetPixel(screenX, screenY, color);

      if (x0 == x1 && y0 == y1)
        break;
      var e2 = err;
      if (e2 > -dx)
      {
        err -= dy;
        x0 += sx;
      }
      if (e2 < dy)
      {
        err += dx;
        y0 += sy;
      }
    }
  }

  public static void Clear(this Canvas canvas, Color clearCol)
  {
    for (int y = 0; y < canvas.Height; ++y)
    {
      for (int x = 0; x < canvas.Width; ++x)
      {
        _ = canvas.SetPixel(x, y, clearCol);
      }
    }
  }

  public static void SkyFill(Canvas canvas)
  {
    for (int y = 0; y < canvas.Height; ++y)
    {
      var colorHsv = new Vector3(0.66F, 0.7F, 0.01F * 0.3F * y);
      var color = HSV2RGB(colorHsv);
      for (var x = 0; x < canvas.Width; ++x)
      {
        canvas.SetPixel(x, y, color);
      }
    }
  }

  public static void SetPixel(this Canvas c, int x, int y, Vector3 col)
  {
    col = Vector3.Clamp(col, Zero, One);
    col = Vector3.SquareRoot(col);
    col *= 255.0F;
    c.SetPixel(x, y, new Color((byte)col.X, (byte)col.Y, (byte)col.Z));
  }

  public static Vector3 HSV2RGB(Vector3 hsv)
  {
    var K = new Vector3(1.0F, 2.0F / 3.0F, 1.0F / 3.0F);
    var p = Vector3.Abs(Fract3(new Vector3(hsv.X) + K) * 6.0F - 3.0F * One);
    return hsv.Z * Vector3.Lerp(One, Vector3.Clamp(p - One, Zero, One), hsv.Y);
  }

  public static bool InWindow(Canvas canvas, int x, int y) => (x >= 0 && x < canvas.Width && y >= 0 && y < canvas.Height);

  private static Vector3 Floor3(Vector3 v)
  {
    return new((float)Math.Floor(v.X), (float)Math.Floor(v.Y), (float)Math.Floor(v.Z));
  }

  private static Vector3 Fract3(Vector3 v)
  {
    return v - Floor3(v);
  }
}