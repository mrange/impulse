open System
open System.Drawing
open System.Drawing.Drawing2D
open System.Windows.Forms

[<Measure>]
type FP;

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
          px      <- px - 2.*round (0.5*px)
          py      <- py - 2.*round (0.5*py)
          pz      <- pz - 2.*round (0.5*pz)
          let r2  = px*px+py*py+pz*pz
          let k   = 1./r2
          px      <- px*k
          py      <- py*k
          pz      <- pz*k
          scale   <- scale*k

        let d = (abs px)/scale
        let c = 
          if d < 0.01 then
            Color.Wheat
          else
            Color.Black

        bitmap.SetPixel (x-1, y-1, c)

  let blob () =
    let t          = 0.
    let mutable s  = cos t, sin t
    for y = height downto 1 do
      for x = width downto 1 do
        let mutable px = float (-width+2*x)/float height
        let mutable py = float (-height+2*y)/float height

        let mutable cpx  = px*4.
        let mutable cpy  = py*4.
        cpx <- cpx - round (cpx)
        cpy <- cpy - round (cpy)
        cpx <- cpx*0.25
        cpy <- cpy*0.25
        let mutable d = cpx*cpx+cpy*cpy

        let mutable bpx = px
        let mutable bpy = py

        for i = 1 to 1 do
          bpx <- bpx+fst s
          bpy <- bpy+snd s

          let bd = bpx*bpx+bpy*bpy

          let bd2= bd-d
          let h1 = 0.5+bd2*4.0
          let h  = min 1.0 h1
          let h2 = 1.0-h

          d <- h2*bd2 + d - 0.125*h*h2
          
        let c = 
          if d < 0.0 then
            Color.Wheat
          else
            Color.Black

        bitmap.SetPixel (x-1, y-1, c)


  let to_fp (i : int) : int<FP> = (i <<< 16)*1<FP>

  let (<+>) (x : int<FP>) (y : int<FP>) : int<FP> = x+y
  let (<->) (x : int<FP>) (y : int<FP>) : int<FP> = x-y
  let (</>) (x : int<FP>) (y : int<FP>) : int<FP> =
    if y = 0<FP> then System.Int32.MaxValue*1<FP>
    else
      let result = ((int64 x) <<< 16) / (int64 y)
      int result*1<FP>

  let (<*>) (x : int<FP>) (y : int<FP>) : int<FP> =
    let result = (int64 x*int64 y) >>> 16
    int result*1<FP>

  let _1    = to_fp 1
  let _2    = to_fp 2
  let _1_6  = to_fp 16 </> to_fp 10
  let _0_5  = _1 </> _2
  let _0_01 = _1 </> to_fp 100

  let fpround (x : int<FP>) : int<FP> = 
    let result = int (x <+> _0_5) &&& 0xFFFF0000
    result*1<FP>

  let fpabs   (x : int<FP>) : int<FP> = 
    if int x = 0x80000000 then to_fp 0x7FFFFFFF
    else
      abs x
  let fplt    (x : int<FP>) (y : int<FP>) : bool = x < y

  let fractal_int () =
    for y = height downto 1 do
      for x = width downto 1 do
        let mutable scale = _1
        let mutable px = (to_fp x <*> _0_01) <-> _1_6
        let mutable py = (to_fp y <*> _0_01) <-> _1
        let mutable pz = _0_01
        for i = 0 to 4 do
          px      <- px<->(_2<*>fpround (_0_5 <*> px))
          py      <- py<->(_2<*>fpround (_0_5 <*> py))
          pz      <- pz<->(_2<*>fpround (_0_5 <*> pz))
          let r2  = (px<*>px)<+>(py<*>py)<+>(pz<*>pz)
          let k   = _1</>r2
          px      <- px<*>k
          py      <- py<*>k
          pz      <- pz<*>k
          scale   <- scale<*>k

        let d = (fpabs px)</>scale
        let c = 
          if fplt d  _0_01 then
            Color.Wheat
          else
            Color.Black

        bitmap.SetPixel (x-1, y-1, c)
    

  use form = new Form (
      Text        = "F# Bitmap Window"
    , ClientSize  = Size (width*scale, height*scale)
    )

  form.Paint.Add <| fun args ->
    blob ()
    args.Graphics.InterpolationMode <- InterpolationMode.NearestNeighbor
    args.Graphics.PixelOffsetMode   <- PixelOffsetMode.Half
    args.Graphics.DrawImage(bitmap, Rectangle(0, 0, width*scale, height*scale))

  Application.Run(form)

  0