// Retro console demo

namespace Impulse2023.Longshot;

using static Lib.Utils;
using static System.Math;

sealed class CubeScreen : Screen
{
  public override string Name => "Longshot/Cube";

  readonly Vector3[] vertices = {
      new(-1F, -1F, -1F), new(1F, -1F, -1F), new(-1F, -1F, 1F),
      new(1F, -1F, 1F), new(-1F, 1F, -1F), new(1F, 1F, -1F),
      new(-1F, 1F, 1F), new(1F, 1F, 1F),
    };

  readonly Vector2[] vertices2d = {
      new(0,0), new(0,0), new(0,0), new(0,0),
      new(0,0), new(0,0), new(0,0), new(0,0)
    };

  readonly Vector2[] lines = {
      new(0, 1), new(0, 2), new(0, 4), new(1, 3), new(1, 5), new(2, 3),
      new(2, 6), new(4, 5), new(4, 6), new(3, 7), new(5, 7), new(6, 7)
    };

  readonly Vector2[] logoI = {
      new(1, 0), new(1, 1), new(1, 2), new(1, 3), new(1, 4),
     new(0, 0), new(2, 0),new(0, 4), new(2, 4)
    };
  readonly Vector2[] logoM = {
      new(0, 0), new(0, 1), new(0, 2), new(0, 3), new(0, 4),
      new(4, 0), new(4, 1), new(4, 2), new(4, 3), new(4, 4),
      new(1, 1), new(2, 2), new(3, 1)
    };
  readonly Vector2[] logoP = {
      new(0, 0), new(0, 1), new(0, 2), new(0, 3), new(0, 4),
      new(1, 0), new(2, 0), new(2, 1), new(2, 2), new(1,2)
    };
  readonly Vector2[] logoU = {
      new(0, 0), new(0, 1), new(0, 2), new(0, 3),
      new(3, 0), new(3, 1), new(3, 2), new(3, 3),
      new(1, 4), new(2, 4),
    };
  readonly Vector2[] logoL = {
      new(0, 0), new(0, 1), new(0, 2), new(0, 3), new(0, 4),
      new(1, 4), new(2, 4), new(3, 4)

    };
  readonly Vector2[] logoS = {
      new(1, 0), new(2, 0), new(3, 0), new(0, 1),
      new(0, 2), new(1, 2), new(2, 2), new(3, 2), new(3, 3),
      new(0, 4), new(1, 4), new(2, 4),
    };
  readonly Vector2[] logoE = {
      new(0, 0), new(0, 1), new(0, 2), new(0, 3), new(0, 4),
      new(1, 0), new(2, 0), new(1, 2), new(1, 4), new(2,4)
    };

  readonly float zoom = 10F;
  readonly float cubeSpeed = 1.5F;

  public CubeScreen()
  {
  }

  public override void Update(Canvas canvas, double time)
  {
    SkyFill(canvas);
    Rasterbars(canvas, time);
    Cube(canvas, time);
    Logo(canvas, time);
  }

  // 2d wire cube
  public void Cube(Canvas canvas, double time)
  {
    var ts = (float)time * cubeSpeed;
    var sx = MathF.Sin(ts);
    var cx = MathF.Cos(ts);
    var sy = MathF.Sin(ts);
    var cy = MathF.Cos(ts);
    var sz = MathF.Sin(0);
    var cz = MathF.Cos(0);

    var letterOffsetX = (int)(Math.Sin(ts) * canvas.Width / 4) - canvas.Width / 38;
    var letterOffsetY = (int)(Math.Cos(ts * 0.7F) * canvas.Height / 7) - canvas.Height / 19;
    var scaleZ = 1.2F * MathF.Sin(ts * 0.8F);

    var colorHsv = new Vector3(0.3F, 0.7F, 0.5F + scaleZ / 3F);
    var color = HSV2RGB(colorHsv);

    for (var i = 0; i < vertices.Count(); i++)
    {
      var x = vertices[i].X;
      var y = vertices[i].Y;
      var z = vertices[i].Z;

      // x rot
      var xy = cx * y - sx * z;
      var xz = sx * y + cx * z;
      // y rot
      var yz = cy * xz - sy * x;
      var yx = sy * xz + cy * x;
      // z rot
      var zx = cz * yx - sz * xy;
      var zy = sz * yx + cz * xy;

      var perspective = canvas.Width;
      var scale = perspective / (perspective + yz) * zoom + 3 * scaleZ;
      vertices2d[i].X = MathF.Round(zx * scale);
      vertices2d[i].Y = MathF.Round(zy * scale);
    }

    for (var j = 0; j < lines.Length; j++)
    {
      int a = (int)lines[j].X;
      int b = (int)lines[j].Y;
      drawLine(vertices2d[a].X, vertices2d[a].Y, vertices2d[b].X, vertices2d[b].Y, letterOffsetX, letterOffsetY, color, canvas);
    }
  }

  // Retro rasterbars
  public void Rasterbars(Canvas canvas, double time)
  {
    var barCount = 3;

    for (int y = 0; y < canvas.Height; y++)
    {
      Vector3? lineColor = null;
      const float barWidth = 0.17F;
      var yPos = 2F * y / canvas.Height - 1F;

      for (int i = 0; i < barCount; ++i)
      {
        var bar = MathF.Abs(yPos + 0.4F * (float)Sin(time + 0.9F * i)) - barWidth;
        if (bar < 0.0)
        {
          var f = MathF.Abs(bar / barWidth);
          lineColor = HSV2RGB(new(0.6F, 1F - 0.6F * f, 1.0F * f));
        }
      }

      if (lineColor.HasValue)
        for (int x = 0; x < canvas.Width; x++)
        {
          canvas.SetPixel(x, y, lineColor ?? Vector3.Zero);
        }
    }
  }

  public void Logo(Canvas canvas, double time)
  {
    var letterOffset = 0;
    var yDistSize = 5;
    var yDistSpeed = 3F;
    var xOffset = (int)(canvas.Width / 3.5);
    var yStart = (int)(canvas.Height / 2.2 + 2F * Sin(time * 2F)); // 8.2
    var logoColor = HSV2RGB(new(0.6F - 0.1F * MathF.Cos((float)time * 5F), 0.4F - 0.1F * MathF.Cos((float)time * 5F), 1.0F - 0.3F * MathF.Sin((float)time * 5F)));

    var yOffset = yStart + (int)(yDistSize * Sin(time * yDistSpeed + 0.0F));
    foreach (var dot in logoI)
    {
      canvas.SetPixel((int)dot.X + letterOffset + xOffset, (int)dot.Y + yOffset, logoColor);
    }
    letterOffset += 5;
    yOffset = yStart + (int)(yDistSize * Sin(time * yDistSpeed + 0.2F));
    foreach (var dot in logoM)
    {
      canvas.SetPixel((int)dot.X + letterOffset + xOffset, (int)dot.Y + yOffset, logoColor);
    }
    letterOffset += 7;
    yOffset = yStart + (int)(yDistSize * Sin(time * yDistSpeed + 0.4F));
    foreach (var dot in logoP)
    {
      canvas.SetPixel((int)dot.X + letterOffset + xOffset, (int)dot.Y + yOffset, logoColor);
    }
    letterOffset += 5;
    yOffset = yStart + (int)(yDistSize * Sin(time * yDistSpeed + 0.6F));
    foreach (var dot in logoU)
    {
      canvas.SetPixel((int)dot.X + letterOffset + xOffset, (int)dot.Y + yOffset, logoColor);
    }
    letterOffset += 6;
    yOffset = yStart + (int)(yDistSize * Sin(time * yDistSpeed + 0.8F));
    foreach (var dot in logoL)
    {
      canvas.SetPixel((int)dot.X + letterOffset + xOffset, (int)dot.Y + yOffset, logoColor);
    }
    letterOffset += 6;
    yOffset = yStart + (int)(yDistSize * Sin(time * yDistSpeed + 1.0F));
    foreach (var dot in logoS)
    {
      canvas.SetPixel((int)dot.X + letterOffset + xOffset, (int)dot.Y + yOffset, logoColor);
    }
    letterOffset += 6;
    yOffset = yStart + (int)(yDistSize * Sin(time * yDistSpeed + 1.2F));
    foreach (var dot in logoE)
    {
      canvas.SetPixel((int)dot.X + letterOffset + xOffset, (int)dot.Y + yOffset, logoColor);
    }
  }
}


