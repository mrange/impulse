open System
open System.Drawing
open System.Drawing.Drawing2D
open System.Windows.Forms


[<STAThread>]
[<EntryPoint>]
let main args =
  let width   = 320
  let height  = 200
  let scale   = 4
  use bitmap = new Bitmap(width, height)
  let fractal () =
    for y = height downto 1 do
      for x = width downto 1 do
        let mutable scale = 1.
        let mutable px = float (-width+2*x)/float height
        let mutable py = float (-height+2*y)/float height
        let mutable pz = 0.01
        for i = 0 to 4 do
          px <- px - 2.*round (0.5*px)
          py <- py - 2.*round (0.5*py)
          pz <- pz - 2.*round (0.5*pz)
          let r2  = px*px+py*py+pz*pz
          let k   = 1./r2
          px    <- px*k
          py    <- py*k
          pz    <- pz*k
          scale <- scale*k

        let d = (abs px)/scale
        let c = 
          if d < 0.01 then
            Color.Wheat
          else
            Color.Black

        bitmap.SetPixel (x-1, y-1, c)
    

  use form = new Form (
      Text        = "F# Bitmap Window"
    , ClientSize  = Size (width*scale, height*scale)
    )

  form.Paint.Add <| fun args ->
    fractal ()
    args.Graphics.InterpolationMode <- InterpolationMode.NearestNeighbor
    args.Graphics.PixelOffsetMode   <- PixelOffsetMode.Half
    args.Graphics.DrawImage(bitmap, Rectangle(0, 0, width*scale, height*scale))

  Application.Run(form)

  0