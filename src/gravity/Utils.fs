namespace GravitySucks

open SharpDX
open SharpDX.Mathematics.Interop

open System

[<AutoOpen>]
module Utils =

    let Deg2Rad = float32 Math.PI/180.F
    let Rad2Deg = 1.F / Deg2Rad

    let inline DefaultOf<'T> = Unchecked.defaultof<'T>

    let inline (!?) (x:^a) : ^b = ((^a or ^b) : (static member op_Implicit : ^a -> ^b) x)

    let rbool       (v : bool)      : RawBool       = !? v
    let rviewPortf  (v : Viewport)  : RawViewportF  = !? v
    let rrectangle  (v : Rectangle) : RawRectangle  = !? v
    let rrectanglef (v : RectangleF): RawRectangleF = !? v
    let rvector2    (v : Vector2)   : RawVector2    = !? v
    let rmatrix3x2  (v : Matrix3x2) : RawMatrix3x2  = !? v
    let rcolor4     (v : Color4)    : RawColor4     = !? v

    let inline V2 x y = Vector2 (x,y)
    let inline ( <*> ) (l : Matrix3x2) (r : Matrix3x2) = Matrix3x2.Multiply (l,r)
    let inline Normalize (v : Vector2) = v.Normalize (); v

    let TryRun (a : unit -> unit) =
        try
            a ()
        with
        | e -> printfn "Caught exception: %A" e

    let TryDispose (d : #IDisposable) =
        if d <> null then
            try
                d.Dispose ()
            with
            | e -> printfn "Caught exception: %A" e

    let TryDisposeList (ds : seq<#IDisposable>) =
        for d in ds do
            TryDispose d


    type Disposer (action : unit->unit) =

        interface IDisposable with
            member x.Dispose () = TryRun action

    let OnExit a = new Disposer (a)