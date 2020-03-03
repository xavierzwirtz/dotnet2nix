module dotnet2nix.Utils

module List =
    let partitionChoice list =
        list
        |> List.fold
            (fun (l1, l2) x ->
                match x with
                | Choice1Of2 x -> l1 @ [x], l2
                | Choice2Of2 x -> l1, l2 @ [x])
            ([], [])