﻿namespace RayTracer

open System.Globalization
open System.Text

type Vector2 =
    {
        X   : float
        Y   : float
    }


    static member New x y = {X = x; Y = y}
    static member Zero = Vector2.New 0. 0.
    static member One = Vector2.New 1. 1.

    static member (+) (x : Vector2, y : Vector2) = Vector2.New (x.X + y.X) (x.Y + y.Y)
    static member (-) (x : Vector2, y : Vector2) = Vector2.New (x.X - y.X) (x.Y - y.Y)
    static member (*) (x : Vector2, y : Vector2) = x.X * y.X + x.Y * y.Y
    static member (*) (s : float  , x : Vector2) = x.Scale s
    static member (*) (x : Vector2, s : float)   = x.Scale s

    member x.Scale s    = Vector2.New (s * x.X) (s * x.Y)
    member x.Normalize  = x * (1. / x.Length)
    member x.L1         = abs (x.X) + abs (x.Y)
    member x.L2         = x * x
    member x.LInf       = max (abs x.X) (abs x.Y)
    member x.Length     = sqrt x.L2
    member x.Min y      = Vector2.New (min x.X y.X) (min x.Y y.Y)
    member x.Max y      = Vector2.New (max x.X y.X) (max x.Y y.Y)
    member x.Lerp y t   = x + t * (y - x)

    member x.Reflect (n : Vector2)  = x - 2.* n * x * n

    override x.ToString () =
        let sb = new StringBuilder()
        sb
            .Append('(')
            .Append(x.X.ToString(CultureInfo.InvariantCulture))
            .Append(',')
            .Append(x.Y.ToString(CultureInfo.InvariantCulture))
            .Append(')')
            .ToString()

type Vector3 =
    {
        X   : float
        Y   : float
        Z   : float
    }


    static member New x y z = {X = x; Y = y; Z = z}
    static member Zero = Vector3.New 0. 0. 0.
    static member One = Vector3.New 1. 1. 1.

    static member (+) (x : Vector3, y : Vector3) = Vector3.New (x.X + y.X) (x.Y + y.Y) (x.Z + y.Z)
    static member (-) (x : Vector3, y : Vector3) = Vector3.New (x.X - y.X) (x.Y - y.Y) (x.Z - y.Z)
    static member (*) (x : Vector3, y : Vector3) = x.X * y.X + x.Y * y.Y + x.Z * y.Z
    static member ( *+* ) (x : Vector3, y : Vector3) = Vector3.New (x.Y * y.Z - x.Z * y.Y) (x.Z * y.X - x.X * y.Z) (x.X * y.Y - x.Y * y.X)
    static member (*) (s : float  , x : Vector3) = x.Scale s
    static member (*) (x : Vector3, s : float)   = x.Scale s

    member x.Scale s    = Vector3.New (s * x.X) (s * x.Y) (s * x.Z)
    member x.Normalize  = x * (1. / x.Length)
    member x.L1         = abs (x.X) + abs (x.Y) + abs (x.Z)
    member x.L2         = x * x
    member x.LInf       = max (max (abs x.X) (abs x.Y)) (abs x.Z)
    member x.Length     = sqrt x.L2
    member x.Min y      = Vector3.New (min x.X y.X) (min x.Y y.Y) (min x.Z y.Z)
    member x.Max y      = Vector3.New (max x.X y.X) (max x.Y y.Y) (max x.Z y.Z)
    member x.Lerp y t   = x + t * (y - x)

    member x.Reflect (n : Vector3)  = x - 2.* n * x * n

    member x.ComputeNormal () =
        if x.X <> 0. then Vector3.New (-(x.Y + x.Z) / x.X) 1. 1.
        elif x.Y <> 0. then Vector3.New 1. (-(x.X + x.Z) / x.Y) 1.
        elif x.Z <> 0. then Vector3.New 1. 1. (-(x.Y + x.X) / x.Z)
        else Vector3.One


    override x.ToString () =
        let sb = new StringBuilder()
        sb
            .Append('(')
            .Append(x.X.ToString(CultureInfo.InvariantCulture))
            .Append(',')
            .Append(x.Y.ToString(CultureInfo.InvariantCulture))
            .Append(',')
            .Append(x.Z.ToString(CultureInfo.InvariantCulture))
            .Append(')')
            .ToString()
