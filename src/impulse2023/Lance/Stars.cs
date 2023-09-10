namespace Impulse2023.Lance;

using static System.Math;

using static Shared;

record Star(Vector3 HSV, Vector4 Pos, Vector2[] ScreenPos)
{
  public int Current = 0;
}

sealed class StarsScreen : Screen
{
  public override string Name => "Lance/Stars";

  readonly Star[] _stars = Stars();

  public static Star[] Stars()
  {
    const int count = 600;
    var stars = new Star[count];
    var rnd = new Random(19740531);

    float Rnd()
    {
      return (float)(-1.0+2.0*rnd!.NextDouble());
    }

    for (int i = 0; i < count; ++i)
    {
      var r = (float)rnd.NextDouble();
      var hsv = new Vector3(0.6F+0.33F*r*r, 0.5F, 1.0F+2.0F*(float)rnd.NextDouble());
      var pos = new Vector4(Rnd(), Rnd(), Rnd(), 1.0F);
      var screenPos = Enumerable.Range(0, 10).Select(x => new Vector2(-1.0F)).ToArray();
      stars[i] = new(hsv, pos, screenPos);
    }

    return stars;
  }

  public override void Update(Canvas canvas, double time)
  {
    var res = new Vector2(canvas.Width, canvas.Height);

    canvas.Clear(Color.Black);

    var p = Matrix4x4.CreatePerspectiveFieldOfView(
        (float)(2.0*PI/6.0)
      , res.X/res.Y
      , 1.0F
      , 2.0F
      );

    var v = Matrix4x4.CreateLookAt(
      new(0.0F, 0.0F,-1.0F)
    , new(0.0F, 0.0F, 0.0F)
    , new(0.0F, 1.0F, 0.0F)
    );

    var m = 
        Matrix4x4.CreateRotationZ(0.5F*(float)time)
//      * Matrix4x4.CreateRotationZ(0.71F*(float)time)
      * Matrix4x4.CreateRotationX(0.33F*(float)time)
      ;

    var t = m*v*p;

    var final = 
        Matrix3x2.CreateScale(0.5F*res.X, 0.5F*res.Y)
      * Matrix3x2.CreateTranslation(0.5F*res.X, 0.5F*res.Y)
      ;

    var offZ = 2.0F*(float)time;

    for (var i = 0; i < _stars.Length; ++i)
    {
      var stari = _stars[i];
      var mstar = stari.Pos;
      mstar.Z -= offZ;
      mstar.X = -1.0F + 2.0F*Fract(0.5F+0.5F*mstar.X);
      mstar.Y = -1.0F + 2.0F*Fract(0.5F+0.5F*mstar.Y);
      mstar.Z = -1.0F + 2.0F*Fract(0.5F+0.5F*mstar.Z);

      var tstar = Vector4.Transform(mstar, t);

      var ndc = (1.0F/tstar.W)*(new Vector3(tstar.X, tstar.Y, tstar.Z));
      if (
            ndc.Z > -1.0F
        &&  ndc.Z <  1.0F
      )
      {
        var newScreen = Vector2.Transform(new(ndc.X, ndc.Y), final);

        stari.ScreenPos[stari.Current] = newScreen;

        for (int j = stari.ScreenPos.Length - 1; j >= 0; j -= 3)
        {
          var screen = stari.ScreenPos[(stari.ScreenPos.Length-j+stari.Current)%stari.ScreenPos.Length];
          var x = (int)Round(screen.X);
          var y = (int)Round(screen.Y);

          if (
                x >= 0 
            &&  x < canvas.Width
            &&  y >= 0
            &&  y < canvas.Height
            )
          {
            var hsv = stari.HSV;
            hsv.Z *= (0.5F-0.5F*ndc.Z)/(1.0F+0.5F*j*j);
            var col = HSV2RGB(hsv);
            canvas.SetPixel(x, y, col);
          }
        }

        stari.Current = (stari.Current+1)%stari.ScreenPos.Length;
      }
    }

  }
}


