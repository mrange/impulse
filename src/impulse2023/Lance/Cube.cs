namespace Impulse2023.Lance;

using System.Numerics;

using static System.Math;
using static System.Numerics.Vector3;
using static Shared;

sealed class CubeScreen : Screen
{
  public override string Name => "Lance/Cube";


  const int MayRayMarches     = 50      ;
  const int MayShadowMarches  = 25      ;

  const float MaxRayLength    = 20.0F   ;
  const float Tolerance       = 1.0E-2F ;
  const float NormalOff       = 0.001F  ;

  static Vector3 SunDir       = Normalize(new Vector3(1.0F, 0.75F, 1.0F))       ;
  static Vector3 SunCol       = HSV2RGB(new(0.075F, 0.8F, 0.05F))       ;
  static Vector3 SkyDir       = Normalize(new(-1.0F, 3.0F, -1.0F))      ;
  static Vector3 SkyCol       = HSV2RGB(new(0.55F, 0.8F, 0.8F))         ;
  static Vector3 GroundCol    = HSV2RGB(new(0.85F, 0.8F, 0.8F))         ;
  static Vector3 BoxCol       = HSV2RGB(new(0.55F, 0.5F, 0.66F))        ;

  static Vector3 RayOrigin    = new(0.0F, 2.0F, 10.0F);
  static Vector3 LookAt       = new(0.0F, 0.0F, 0.0F);
  static Vector3 Up           = new(0.0F, 1.0F, 0.0F);

  static Plane PlaneDim       = new(new(0.0F, 1.0F, 0.0F), 6.0F);

  static float FOV            = (float)Tan(2.0*PI/6.0);

  float Bounce                = 0.0F;
  Matrix4x4 Transform0        = Matrix4x4.Identity;

  public override void Update(Canvas canvas, double time_)
  {
    var time = (float)time_;
    var w = canvas.Width;
    var h = canvas.Height;
    var res = new Vector2(w, h);

    var logo = new float[w*h];

    for (int y = 0; y < h; ++y)
    {
      for (int x = 0; x < w; ++x)
      {
        var q = new Vector2(x, y)/res;
        q.Y = 1.0F-q.Y;
        var p = -Vector2.One+2.0F*q;
        p.X *= res.X/res.Y;

        float d = Lug00ber(p)-0.025F;
        float aa = 1.0F/res.Y;
        logo[x+w*y] = Smoothstep(aa, -aa, d);
      }
    }

    static Vector3? RasterBar(float time, int y, Vector2 res)
    {
      const double w = 0.125;
      var ry = 2.0F*y/res.Y-1.0F;

      Vector3? rasterBar = null;

      for (int i = 0; i < 7; ++i)
      {
        var rd = Abs(ry+0.4*Sin(time+0.4F*i)+0.2)-w;
        if (rd < 0.0)
        {
          var f = (float)Abs(rd/w);
          rasterBar = HSV2RGB(new(i/7.0F, 1.0F-0.5F*f, 1.5F*f));
        }
      }

      return rasterBar;
    }

    var ro  = RayOrigin;
    var a   = (float)time*0.1;
    ro.X    = (float)(Cos(a)*RayOrigin.X+Sin(a)*RayOrigin.Z);
    ro.Z    = (float)(-Sin(a)*RayOrigin.X+Cos(a)*RayOrigin.Z);
    var ww  = Normalize(LookAt - ro);
    var uu  = Normalize(Cross(Up, ww));
    var vv  = Cross(ww, uu);

    float ft= Fract((float)time*0.5F)-0.5F;
    Bounce = 20.0F*ft*ft;

    Transform0 = 
        Matrix4x4.CreateRotationX(0.923F*time)
      * Matrix4x4.CreateRotationY(0.731F*time)
      * Matrix4x4.CreateRotationZ(0.521F*time);

    Parallel.For(0, h, y =>
    {
      for (int x = 0; x < w-1; ++x)
      {
        canvas.SetPixel(x, y, Compute(res, ww, uu, vv, ro, 1.0F, logo, RasterBar(time, y, res), x, y));
      }
    });
  }

  float DistanceField(Vector3 p) 
  {
    var p0 = p;
    var p1 = p;
    p1.Y += Bounce;
    p1 = Abs(p1);
    p1.X -= 5.0F;
    p1.Z -= 5.0F;

    p0 = Transform(p0, Transform0);

    float d0 = Sphere8(p0, 3.5F);
    float d1 = Sphere(p1, 1.0F);
    float d = d0;
    d = Min(d, d1);
    return d;
  }

  float RayMarch(Vector3 ro, Vector3 rd) 
  {
    float t     = 0.0F;

    for (int i = 0; i < MayRayMarches; ++i) {
      if (t > MaxRayLength) break;
      float d = DistanceField(ro + rd*t);
      if (d < Tolerance) break;
      t += d;
    }

    return t;
  }

  Vector3 Normal(Vector3 pos) {
    var epsx = new Vector3(NormalOff, 0.0F, 0.0F);
    var epsy = new Vector3(0.0F, NormalOff, 0.0F);
    var epsz = new Vector3(0.0F, 0.0F, NormalOff);
    return Normalize(new(
        DistanceField(pos+epsx)-DistanceField(pos-epsx)
      , DistanceField(pos+epsy)-DistanceField(pos-epsy)
      , DistanceField(pos+epsz)-DistanceField(pos-epsz))
      );
  }

  float SoftShadow(Vector3 ps, Vector3 ld, float mint, float k)
  {
    float res = 1.0F;
    float t = mint*6.0F;
    for (int i=0; i<MayShadowMarches; ++i) 
    {
      Vector3 p = ps + ld*t;
      float d = DistanceField(p);
      res = Min(res, k*d/t);
      if (res < Tolerance) break;
      t += Max(d, mint);
    }
    return Min(Max(res, 0.0F), 1.0F);
  }

  Vector3 Compute(Vector2 res, Vector3 ww, Vector3 uu, Vector3 vv, Vector3 ro, float fade, float[] logo, Vector3? rasterBar, int x, int y)
  {
    var q = new Vector2(x, y)/res;
    q.Y = 1.0F-q.Y;
    var p = -Vector2.One+2.0F*q;
    p.X *= res.X/res.Y;
    var rd = Normalize(-p.X*uu + p.Y*vv+FOV*ww);

    var tp = RayPlane(ro, rd, PlaneDim);
    var te = RayMarch(ro, rd);

    var col = Zero;

    if (te < MaxRayLength && (tp < 0.0 || te < tp)) 
    {
      var ep = ro+rd*te;
      var en = Normal(ep);
      var er = Reflect(rd, en);
    
      var sunDif = Max(Dot(en, SunDir), 0.0F);
      var skyDif = Max(Dot(en, SkyDir), 0.0F);
      var sunSpe = (float)Pow(Max(Dot(er, SunDir), 0.0F), 10.0);
      sunDif *= sunDif;

      col += 0.1F*GroundCol + sunDif*One + skyDif*SquareRoot(SkyCol);
      col *= BoxCol;
      col += sunSpe*One;
    } 
    else if (tp > 0.0F)
    {
      if (rasterBar is not null)
      {
        col = rasterBar.Value;
      }
      else
      {
        var gp = ro+rd*tp;
        var gn = PlaneDim.Normal;
        var gr = Reflect(rd, gn);

        var sunDif = Max(Dot(gn, SunDir), 0.0F);
        var sunSpe = (float)Pow(Max(Dot(gr, SunDir), 0.0F), 10.0);
        sunDif *= sunDif;

        var sf = SoftShadow(gp, SunDir, 0.1F, 8.0F);
        col += 1.5F*sf*sunDif*One+0.25F*SquareRoot(SkyCol);
        col *= GroundCol;
        col += sunSpe*One;
        col /= 1.0F+0.0025F*tp*tp;
      }
    } 
    else
    {
      if (rasterBar is not null)
      {
        col = rasterBar.Value;
      }
      else
      {
        col += SkyCol;
        col += SunCol/(1.01F-Dot(rd, SunDir));
        col += new Vector3((float)(0.1/Max(Sqrt(rd.Y), 0.2)));
      }
    }

    col = Clamp(col, Zero, One);

    col = Lerp(col, One, logo[x + (int)(y*res.X)]);

    col *= fade;

    return col;
  }

}


