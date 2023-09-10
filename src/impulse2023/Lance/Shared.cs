namespace Impulse2023.Lance;

using static System.Math;
using static System.Numerics.Vector3;

record Plane(Vector3 Normal, float Offset);

static class Shared
{
  public static float Fract(float v)
  {
    return (float)(v - Floor(v));
  }

  public static Vector3 Floor3(Vector3 v)
  {
    return new((float)Floor(v.X), (float)Floor(v.Y), (float)Floor(v.Z));
  }

  public static Vector3 Fract3(Vector3 v)
  {
    return v - Floor3(v);
  }

  public static float Lerp(float a, float b, float t)
  {
    return a + t*(b-a);
  }

  public static float Smoothstep(float edge0, float edge1, float x)
  {
    float t = Clamp((x - edge0) / (edge1 - edge0), 0.0F, 1.0F);
    return t * t * (3.0F - 2.0F * t);
  }

  public static float PMin(float a, float b, float k) 
  {
    float h = Clamp(0.5F+0.5F*(b-a)/k, 0.0F, 1.0F);
    return Lerp(b, a, h) - k*h*(1.0F-h);
  }

  public static Vector3 HSV2RGB(Vector3 hsv) 
  {
    var K = new Vector3(1.0F, 2.0F / 3.0F, 1.0F / 3.0F);
    var p = Abs(Fract3(new Vector3(hsv.X) + K) * 6.0F - 3.0F*One);
    return hsv.Z * Vector3.Lerp(One, Clamp(p - One, Zero, One), hsv.Y);
  }

  public static void SetPixel(this Canvas c, int x, int y, Vector3 col)
  {
    col = Clamp(col, Zero, One);
    col = SquareRoot(col);
    col *= 255.0F;
    c.SetPixel(x, y, new Color((byte)col.X, (byte)col.Y, (byte)col.Z));
  }

  public static float Box(Vector2 p, Vector2 b) 
  {
    var d = Vector2.Abs(p)-b;
    return Vector2.Max(d,Vector2.Zero).Length() + Max(Max(d.X,d.Y),0.0F);
  }

  public static float Segment(Vector2 p, Vector2 a, Vector2 b) 
  {
      var pa = p-a;
      var ba = b-a;
      float h = Clamp(Vector2.Dot(pa,ba)/Vector2.Dot(ba,ba), 0.0F, 1.0F);
      return (pa - ba*h).Length();
  }

  public static float Lug00ber(Vector2 p) {
    var p0 = p;
    p0.Y = Abs(p0.Y);
    p0 -= new Vector2(-0.705F, 0.41F);
    float d0 = p0.Length()-0.16F;
  
    var topy = 0.68F;
    var bp = p-new Vector2(0.27F, -0.8F);
    var d1 = Segment(p, new(0.72F, topy), new(0.27F, -0.8F))-0.06F;
    var d2 = Segment(p, new(-0.13F, topy), new(0.33F, -0.8F))-0.1F;
    var d3 = p.Y-(topy-0.066F);

    var d4 = Box(p-new Vector2(-0.1F, topy), new(0.25F, 0.03F))-0.01F;
    var d5 = Box(p-new Vector2(0.685F, topy), new(0.19F, 0.03F))-0.01F;
    var d6 = Min(d4, d5);
  
    var ax7   = Vector2.Normalize(new Vector2(0.72F, topy)-new Vector2(0.27F, -0.8F));
    var nor7  = new Vector2(ax7.Y, -ax7.X);
    var d7    = Vector2.Dot(p, nor7)+Vector2.Dot(nor7, -new Vector2(0.72F, topy))+0.05F;
  
    d2 = Max(d2, d7);
    float d = d1;
    d = PMin(d,d2, 0.025F);
    d = Max(d, d3);
    d = PMin(d, d6, 0.1F);
    d = Min(d,d0);
  
    return d; 
  }

  public static float RayPlane(Vector3 ro, Vector3 rd, Plane p)
  {
    return -(Dot(ro,p.Normal)+p.Offset)/Dot(rd,p.Normal);
  }

  public static float Sphere8(Vector3 p, float r) {
    p *= p;
    p *= p;
    return ((float)Pow(Dot(p, p), 0.125))-r;
  }

  public static float Sphere(Vector3 p, float r) {
    return p.Length() - r;
  }

}