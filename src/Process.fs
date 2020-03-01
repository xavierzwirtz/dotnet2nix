module dotnet2nix.Process

open System
open System.IO

exception Fail of string
let fail message =
    raise (Fail message)

type ExecResult=
    { exitCode : int
      error : string
      output : string
    }

let printArguments (arguments : string seq) =
    arguments
    |> Seq.map(fun x -> "\"" + x + "\"") //TODO this could use proper escaping
    |> String.concat " "
    
let exec fileName arguments =
    let psi = new System.Diagnostics.ProcessStartInfo()
    let arguments = printArguments arguments
    Logging.tracefn "%s %s" fileName arguments
    psi.FileName <- fileName
    psi.Arguments <- arguments
    psi.UseShellExecute <- false
    psi.RedirectStandardOutput <- true
    psi.RedirectStandardError <- true

    let proc = new System.Diagnostics.Process()
    proc.StartInfo <- psi

    let mutable output = []
    let mutable error = []
    proc.OutputDataReceived.Add(fun e -> 
        output <- output @ [System.Environment.NewLine; e.Data])
    proc.ErrorDataReceived.Add(fun e ->
        error <- error @ [System.Environment.NewLine; e.Data])

    let tcs = new System.Threading.Tasks.TaskCompletionSource<_>()
    proc.EnableRaisingEvents <- true;
    proc.Exited.Add(fun _ ->
        tcs.SetResult(null))
    
    if proc.Start() |> not then
        fail (sprintf "failed to start %s" fileName)

    proc.BeginOutputReadLine()
    proc.BeginErrorReadLine()

    async {
        let! _ = tcs.Task |> Async.AwaitTask 

        proc.WaitForExit()
        
        let error = error |> String.concat ""
        let output = output |> String.concat ""
        
        return
            { exitCode = proc.ExitCode
              error = error
              output = output
            }
        
    }
    
let execSuccess fileName arguments =
    async {
        let! result = exec fileName arguments
        return
            if result.exitCode <> 0 then
                fail (sprintf "'%s %s' failed with code %i"
                              fileName (printArguments arguments) result.exitCode)
            else result    
    }

