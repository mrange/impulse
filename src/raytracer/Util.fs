﻿namespace RayTracer

open System
open System.Windows.Threading

[<AutoOpen>]
module Util =

    let cutoff = 0.000001

    let sign d = if d < 0. then -1. else 1.
    let pi = Math.PI
    let pi2 = 2. * pi

    let degree2rad d = pi * d / 180.
    let rad2degree r = r * 180. / pi

    let clamp x min max =
        if x < min then min
        elif x > max then max
        else x

    let norm x = clamp x -1. 1.
    let unorm x = clamp x 0. 1.

    let dispatch (d : Dispatcher) (a : unit -> unit) =
        let a' = Action a
        ignore <| d.BeginInvoke (DispatcherPriority.ApplicationIdle, a')

    let asByte d = byte ((unorm d) * 255.)


