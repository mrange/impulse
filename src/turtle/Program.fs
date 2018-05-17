open System

open TurtlePower

[<STAThread>]
[<EntryPoint>]
let main argv =
    let turtleGenerator = 
      match argv |> Array.tryItem 0 with
      | Some "optimized_tree" -> OptimizedTreeFractal.Generate 10 250.F
      | Some "other_tree"     -> OtherTreeFractal.Generate 8 250.F
      | Some "waving_tree"    -> WavingTreeFractal.Generate 10 250.F
      | Some "box"            -> Box.Generate 500.F
      | Some "recursive_box"  -> RecursiveBox.Generate 500.F
      | Some "simple_tree"    -> SimpleTreeFractal.Generate 10 250.F
      | Some "tree"           -> TreeFractal.Generate 10 250.F
      | _                     -> SimpleBox.Generate 500.F

    TurtleWindow.Show turtleGenerator

    0
