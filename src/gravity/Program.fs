open GravitySucks

open Gravity

open System

// TODO:
// 1. Implement spatial tree to be able to crank up particle count
// 2. Keep largest particles from spatial tree as they are the ones most likely to affect the trajectory
//    and needs precision
// 3. Implement concurrent algorithm

type Random with

    member x.NextFloat (inclusiveFrom : float) (inclusiveTo : float) =
        let n = x.NextDouble ()
        inclusiveFrom + n * (inclusiveTo - inclusiveFrom)



[<EntryPoint>]
let main argv =

    let random      = Random (19740531)

    let pi          = Math.PI
    let tau         = 2. * pi

    let createParticle (c : Particle) (m : float) (r : float) (a : float) (s : float) =
        let x   = float32 <| r * sin a
        let y   = float32 <| r * cos  a
        let p   = Particle.New (float32 m) (c.Current + (V2 x y)) (V2 0.F 0.F)
        let gf  = float <| c.GravityForce p
        let v   = s * sqrt (r * gf / m)
        let vx  = float32 <| v * cos a
        let vy  = float32 <| - v * sin a
        p.Velocity <- c.Velocity + (V2 vx vy)
        p

    let center  = Particle.New 1000000.F (V2 0.F 0.F) (V2 0.F 0.F)
    let planet m r =
      let a       = random.NextFloat 0. tau
      let planet  = createParticle center m r a 1.
      let moon1   = createParticle planet (m / 50.) 50. 0. 1.
      [| planet; moon1|]
    
    let predefined =
        [|
            yield center
            yield! planet 7500. 1300.
            yield! planet 7500. 1100.
            yield! planet 7500. 900. 
            yield! planet 7500. 700. 
            yield! planet 7500. 500. 
        |]

    let count = 256
    let particles =
        [|
            for i in 0..(count - 1) do
                if i < predefined.Length then yield predefined.[i]
                else
                    let cm  = center.Mass
                    let m   = random.NextFloat 10.    30.
                    let r   = random.NextFloat 150.   800.
                    let a   = random.NextFloat 0.     tau
                    let s   = random.NextFloat 0.9    1.2
                    let p   = createParticle center m r a s
                    yield p
        |]

    Window.Show particles
    0
