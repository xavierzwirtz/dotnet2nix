// forked from https://github.com/fsprojects/Paket/blob/be93df8771c05f57f941913ea6d30c0674aea624/src/Paket.Core/Common/Logging.fs
//The MIT License (MIT)
//
//Copyright (c) 2015 Alexander Groß, Steffen Forkmann
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE

module dotnet2nix.Logging

open System
open System.IO
open System.Diagnostics
open System.Collections.Concurrent
open System.Threading

/// [omit]
let mutable verbose = false
let mutable silent = false

/// [omit]
type Trace = {
    Level: TraceLevel
    Text: string
    NewLine: bool }

/// [omit]
let event = Event<Trace>()


/// [omit]
let tracen s =
    if not silent then
        event.Trigger { Level = TraceLevel.Info; Text = s; NewLine = true }

/// [omit]
let tracefn fmt = Printf.ksprintf tracen fmt

/// [omit]
let trace s = event.Trigger { Level = TraceLevel.Info; Text = s; NewLine = false }

/// [omit]
let tracef fmt = Printf.ksprintf trace fmt

/// [omit]
let traceVerbose s =
    if verbose then
        event.Trigger { Level = TraceLevel.Verbose; Text = s; NewLine = true }

/// [omit]
let verbosefn fmt = Printf.ksprintf traceVerbose fmt

/// [omit]
let traceError s = event.Trigger { Level = TraceLevel.Error; Text = s; NewLine = true }

/// [omit]
let traceWarn s = event.Trigger { Level = TraceLevel.Warning; Text = s; NewLine = true }

/// [omit]
let traceErrorfn fmt = Printf.ksprintf traceError fmt

/// [omit]
let traceWarnfn fmt = Printf.ksprintf traceWarn fmt

let private omittedWarnings = ref 0
let private warnings = ConcurrentDictionary<obj,Guid>()
let traceIfNotBefore tracer key fmt =
    let printer =
        if verbose then tracer
        else
            let g = Guid.NewGuid()
            if g = warnings.GetOrAdd(key, fun _ -> g) then
                tracer
            else
                Interlocked.Increment(omittedWarnings) |> ignore
                ignore

    Printf.ksprintf printer fmt

let getOmittedWarningCount () = omittedWarnings.Value

let traceWarnIfNotBefore key fmt = traceIfNotBefore traceWarn key fmt
let traceErrorIfNotBefore key fmt = traceIfNotBefore traceError key fmt

// Console Trace

/// [omit]
let traceColored color (s:string) =
    let curColor = Console.ForegroundColor
    if curColor <> color then Console.ForegroundColor <- color
    use textWriter = Console.Error

    textWriter.WriteLine s
    if curColor <> color then Console.ForegroundColor <- curColor

/// [omit]
let monitor = new Object()

/// [omit]
let traceToConsole (trace:Trace) =
    lock monitor
        (fun () ->
            match trace.Level with
            | TraceLevel.Warning -> traceColored ConsoleColor.Yellow trace.Text
            | TraceLevel.Error -> traceColored ConsoleColor.Red trace.Text
            | _ ->
                if trace.NewLine then Console.Error.WriteLine trace.Text
                else Console.Error.Write trace.Text )


// Log File Trace

/// [omit]
let mutable logFile : string option = None

/// [omit]
let traceToFile (trace:Trace) =
    match logFile with
    | Some fileName -> try File.AppendAllLines(fileName,[trace.Text]) with | _ -> ()
    | _ -> ()

/// [omit]
let setLogFile fileName =
    let fi = FileInfo fileName
    logFile <- Some fi.FullName
    if fi.Exists then
        fi.Delete()
    else
        if fi.Directory.Exists |> not then
            fi.Directory.Create()
    event.Publish |> Observable.subscribe traceToFile

/// [omit]
[<RequireQualifiedAccess>]
type private ExnType =
    | First
    | Aggregated
    | Inner

/// [omit]
let printErrorExt printFirstStack printAggregatedStacks printInnerStacks (exn:exn) =
    let defaultMessage = AggregateException().Message
    let rec printErrorHelper exnType useArrow indent (exn:exn) =
        let handleError () =
            let s = if useArrow then "->" else "- "
            let indentString = String('\t', indent)
            let splitMsg = exn.Message.Split([|"\r\n"; "\n"|], StringSplitOptions.None)
            let typeString =
                let t = exn.GetType()
                if t = typeof<Exception> || t = typeof<AggregateException> then
                    ""
                else sprintf "%s: " t.Name
            traceErrorfn "%s%s %s%s" indentString s typeString (String.Join(sprintf "%s%s   " Environment.NewLine indentString , splitMsg))

            let printStack =
                match String.IsNullOrWhiteSpace exn.StackTrace, exnType with
                | false, ExnType.First when printFirstStack -> true
                | false, ExnType.Aggregated when printAggregatedStacks -> true
                | false, ExnType.Inner when printInnerStacks -> true
                | _ -> false

            if printStack then
                traceErrorfn "%s   StackTrace:" indentString
                let split = exn.StackTrace.Split([|"\r\n"; "\n"|], StringSplitOptions.None)
                traceErrorfn "%s     %s" indentString (String.Join(sprintf "%s%s     " Environment.NewLine indentString, split))

        match exn with
        | :? AggregateException as aggr ->
            if aggr.InnerExceptions.Count = 1 then
                let inner = aggr.InnerExceptions.[0]
                if aggr.Message = defaultMessage || aggr.Message = inner.Message then
                    // skip as no new information is available.
                    printErrorHelper exnType useArrow indent inner
                else
                    handleError()
                    printErrorHelper ExnType.Aggregated true indent inner
            else
                handleError()
                for inner in aggr.InnerExceptions do
                    printErrorHelper ExnType.Aggregated false (indent + 1) inner
        | _ ->
            handleError()
            if not (isNull exn.InnerException) then
                printErrorHelper ExnType.Inner true indent exn.InnerException

    printErrorHelper ExnType.First true 0 exn

/// [omit]
let printError (exn:exn) =
    printErrorExt verbose verbose false exn