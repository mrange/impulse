namespace Impulse2023.Lance;

using static System.Math;

using static Shared;

sealed class RasterBarsScreen : Screen
{
  public override string Name => "Lance/Rasterbars";

  public override void Update(Canvas canvas, double time)
  {
    var res = new Vector2(canvas.Width, canvas.Height);

    for (int y = 0; y < canvas.Height; ++y)
    {
      const double w = 0.2;
      var ry = 2.0F*y/res.Y-1.0F;

      Vector3? rasterBar = null;

      for (int i = 0; i < 7; ++i)
      {
        var rd = Abs(ry+0.5*Sin(time+0.4F*i))-w;
        if (rd < 0.0)
        {
          var f = (float)Abs(rd/w);
          rasterBar = HSV2RGB(new (i/7.0F, 1.0F-0.5F*f, 1.5F*f));
        }
      }

      for (int x = 0; x < canvas.Width; ++x)
      {
        canvas.SetPixel(x, y, rasterBar??Vector3.Zero);
      }
    }

  }
}


