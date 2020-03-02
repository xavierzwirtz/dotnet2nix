module dotnet2nix.Program
open Argu
open Logging
open Process
open System
open System.IO
open Newtonsoft.Json.Linq
open FSharp.Collections.ParallelSeq
open Paket
open Paket

type CliArguments =
    | [<Unique>] Verbose
    | [<Unique>] Silent
    | [<Unique>] Project of string
with
    interface IArgParserTemplate with
        member s.Usage =
            match s with
            | Verbose -> "enables verbose logging"
            | Silent -> "disables logging"
            | Project _ -> "Project or solution file to run dotnet commands against"

type NuGetDependency =
    { name : string
      version : string
      url : string
      transitive : bool }

type GitHubDependency =
    { owner : string
      repo : string
      file : string
      commit : string
      hashType : string
      hash : string }
    
type DependencyGroup =
    { group : Domain.GroupName option
      nugetDependencies : NuGetDependency list
      githubDependencies : GitHubDependency list
    }
    
type Dependencies =
    { groups : DependencyGroup list
    }
    
let resolvePackageUrl (packageName : Domain.PackageName) (version : SemVerInfo) sources transitive =
    async {
        let packageName' = packageName.Name.ToString()
        let version' = version.Normalize()
        tracefn "resolving %s %s" (packageName') (version')
        let force = true
            
        let getPackageDetails () =
            NuGet.GetPackageDetails
                None
                (Directory.GetCurrentDirectory())
                force
                (PackageResolver.GetPackageDetailsParameters.ofParams
                    sources
                    Constants.MainDependencyGroup
                    packageName
                    version)
                
        if not transitive then
            let! nugetPackage = getPackageDetails()
            return
                { name = packageName'
                  version = version'
                  url = nugetPackage.DownloadLink
                  transitive = transitive
                } |> Some
        else
            try
                let! nugetPackage = getPackageDetails()
                return
                    { name = packageName'
                      version = version'
                      url = nugetPackage.DownloadLink
                      transitive = transitive
                    } |> Some
            with
            | ex ->
                if ex.Message.StartsWith("Couldn't get package details for package") then
                    return None
                else
                    return raise ex
    }
let parseNugetDependencies (sources : PackageResolver.PackageResolution) =
    groupBySources sources
    |> Seq.map(fun (source, packages) ->
        packages
        |> Seq.map(fun (_, _, package) ->
            resolvePackageUrl package.Name package.Version [package.Source] false
        ))
    |> Seq.concat
    |> Seq.toList
         
let parseRemoteFileDependencies (remoteFiles : ModuleResolver.ResolvedSourceFile list) =
    remoteFiles
    |> Seq.map(fun source ->
        match source.Origin with
        | ModuleResolver.GitHubLink ->
            async {
                tracefn "prefetching github %s %s" source.Owner source.Project
                let! hashResp =
                    execSuccess "nix-prefetch-github" [
                        source.Owner; source.Project; "--rev"; source.Commit ]
                let hashResp = hashResp.output |> JObject.Parse
                let hashType = "sha256"
                let hash = hashResp.Item(hashType).ToObject<string>()
                
                return
                    { owner = source.Owner
                      repo = source.Project
                      commit = source.Commit
                      hash = hash
                      hashType = hashType
                      file = source.Name }
            }
        | _  -> fail (sprintf "unsupported remote file origin %A" source.Origin)
    )
    |> PSeq.toList
    
let getPaketDependencies () =
    tracefn "parsing paket.dependencies"
    let dependencies = Paket.Dependencies.TryLocate()
    match dependencies with
    | None -> 
        tracefn "paket.dependencies not found"
        { groups = [] }
    | Some dependencies -> 
        tracefn "parsing paket.lock"
        let lockFile = dependencies.GetLockFile()
        
        tracefn "getting package urls and hashes"
        let groups =
            lockFile.Groups
            |> Seq.map(fun group ->
                async {
                    let! nugetDependencies =
                        parseNugetDependencies group.Value.Resolution
                        |> Async.Parallel
                        
                    let! githubDependencies =
                        parseRemoteFileDependencies group.Value.RemoteFiles    
                        |> Async.Parallel
                        
                    let groupName =
                        if group.Key = Paket.Constants.MainDependencyGroup then None
                        else Some group.Key
                    return
                        { group = groupName
                          nugetDependencies = nugetDependencies |> List.ofArray |> List.choose id
                          githubDependencies = githubDependencies |> List.ofArray
                        }
                }
            )
            |> Async.Parallel
            |> Async.RunSynchronously
            |> Seq.toList
        { groups = groups }

type DotNetParseState =
| NotStarted
| InProject
| TopLevelPackages of int * int
| TransitivePackages of int

let topLevelPackagesRe =
    System.Text.RegularExpressions.Regex("(?<name>Top-level Package) +(?<requested>Requested) +(?<resolved>Resolved)")
let transitivePackagesRe =
    System.Text.RegularExpressions.Regex("(?<name>Transitive Package) +(?<resolved>Resolved)")
let getNugetDependencies nugetSources project =
    let dotnetOutput =
        execSuccess "dotnet"
            (["list"] @ 
             (match project with
              | None -> []
              | Some project -> [project]) @
             ["package"; "--include-transitive"])
        |> Async.RunSynchronously
    
    let lines =
        dotnetOutput.output.Split([|'\r'; '\n'|], System.StringSplitOptions.None)

    let (packages, _) =
        lines |> Array.fold
            (fun (prior, state) line ->
                let adv newState = (prior, newState)
                let cont = (prior, state)
                let add package = (prior @ [package], state)
                let line = line.Trim()
                let bad () =
                    fail (sprintf "could not parse 'dotnet list package'\nline: %s\nstate: %A\noutput:%s"
                                  line
                                  state
                                  dotnetOutput.output)
                let rec parse state =
                    if line = "" then cont
                    else if line.StartsWith("(A) : Auto-referenced package.") then cont
                    else if line.StartsWith("Project '") then
                        adv InProject
                    else 
                        match state with
                        | NotStarted -> bad()
                        | InProject ->
                            if line.StartsWith("[") then
                                cont
                            else
                                let m = topLevelPackagesRe.Match(line)
                                if m.Success then
                                    let name = m.Groups.Item("name")
                                    let requested = m.Groups.Item("requested")
                                    let resolved = m.Groups.Item("resolved")
                                    adv(TopLevelPackages (requested.Index, resolved.Index))
                                else
                                    let m = transitivePackagesRe.Match(line)
                                    if m.Success then
                                        let name = m.Groups.Item("name")
                                        let resolved = m.Groups.Item("resolved")
                                        adv(TransitivePackages (resolved.Index))
                                    else bad()
                        | TopLevelPackages (requestedIndex, resolvedIndex) ->
                            if line.StartsWith(">") |> not then parse InProject
                            else
                                let name = line.Substring(1, requestedIndex - 1).Trim()
                                let resolved = line.Substring(resolvedIndex).Trim()
                                add(name, resolved, false)
                        | TransitivePackages (resolvedIndex) ->
                            if line.StartsWith(">") |> not then parse InProject
                            else
                                let name = line.Substring(1, resolvedIndex - 1).Trim()
                                let resolved = line.Substring(resolvedIndex).Trim()
                                add(name, resolved, true)
                let (result, state) = parse state
                result, state
            )
            ([], NotStarted)        
    
    packages
    |> List.map(fun (name, version, transative) ->
        let name =
            if name.EndsWith "(A)" then name.Substring(0, name.Length - 3).Trim()
            else name
        resolvePackageUrl (Domain.PackageName(name)) (SemVer.Parse version) nugetSources transative)
    |> Async.Parallel
    |> Async.RunSynchronously
    |> List.ofArray
    
type HashedNuGetDependency =
    { nugetDependency : NuGetDependency
      hashType : string
      hash : string }
    
let cleanNugetDependencies (dependencies : NuGetDependency list) =
    dependencies
    |> List.groupBy (fun x ->
        x.name, x.version)
    |> List.map(fun ((name,version), grouped) ->
        async {
            let hd = grouped |> List.head
            let hashType = "sha256"

            let! hashRaw = execSuccess "nix-prefetch-url" [
                hd.url
                "--type"; hashType
            ]
            let hash = hashRaw.output.Trim('\r', '\n')

            return
                { nugetDependency = hd
                  hashType = hashType
                  hash = hash
                }
        }

    )

let printNuGetDependency (nuget : HashedNuGetDependency) =
    printfn """    (
      fetchNuGet {
        name = "%s";
        version = "%s";
        url = "%s";
        %s = "%s";
      }
    )"""
            nuget.nugetDependency.name 
            nuget.nugetDependency.version 
            nuget.nugetDependency.url 
            nuget.hashType
            nuget.hash
            
let printGitHubDependency
    (group :Domain.GroupName option)
    (github : GitHubDependency) =
    printfn """    (
      fetchFromGitHubForPaket {
        group = %s;
        owner = "%s";
        repo = "%s";
        rev = "%s";
        file = "%s";
        %s = "%s";
      }
    )"""
            (match group with
             | None -> "null"
             | Some (x) -> "\"" + x.ToString().ToLower() + "\"")
            github.owner
            github.repo 
            github.commit
            github.file
            github.hashType 
            github.hash
            
let outputDependencies nugetDependencies (dependencies : Dependencies) =
    traceVerbose (sprintf "parsed dependencies: %A" dependencies)
    
    printfn """{ fetchurl
, fetchFromGitHub
, stdenv
, lib
, unzip
}:
let
  fetchNuGet = { url, name, version, ... } @ attrs:
    stdenv.mkDerivation {
      name = name;
      pversion = version;
      phases = [ "buildPhase" ];
      src = fetchurl (
        (
          builtins.removeAttrs attrs [
            "version"
          ]
        ) // {
          inherit name url;
        }
      );
      dontUnpack = true;
      buildPhase = ''
        mkdir -p "$out"
        cp $src "$out/${lib.strings.toLower name}.${lib.strings.toLower version}.nupkg"
      '';
    };
  fetchFromGitHubForPaket = { group, owner, repo, rev, file, ... } @ attrs:
    let
      group2 =
        if group == null then "" else "${group}/";
    in
      stdenv.mkDerivation {
        name = "${if group == null then "" else "${group}_"}${owner}_${repo}_${builtins.replaceStrings [ "/" "_" ] [ "_" "__" ] file}";
        pversion = rev;
        phases = [ "buildPhase" ];
        src = fetchFromGitHub (
          (
            builtins.removeAttrs attrs [
              "file"
              "group"
            ]
          )
        );
        buildPhase = ''
          fileDir=$(dirname "$out/${group2}${owner}/${repo}/${file}")
          mkdir -p "$fileDir"
          cp "$src/${file}" "$out/${group2}${owner}/${repo}/${file}"
          echo "${rev}" > "$fileDir/paket.version"
        '';
      };
in
{
  nuget = ["""
    for nuget in nugetDependencies do
        printNuGetDependency nuget
        
    printfn """  ];
  github = ["""
    for group in dependencies.groups do    
        for github in group.githubDependencies do
            printGitHubDependency group.group github
    printfn """  ];
}"""
    
let getNugetSources () =
    // TODO this should look for a NuGet.Config and parse the data from it
    // use list of sources from paket.dependencies if availible
    [ Paket.PackageSources.PackageSource.Parse "nuget https://api.nuget.org/v3/index.json" ]

let run (parserResults : ParseResults<CliArguments>) =
    
    let project = parserResults.TryGetResult <@ Project @>
    let paketDependencies = getPaketDependencies ()
    let nugetSources = getNugetSources ()
    let nugetDependencies =
        getNugetDependencies nugetSources project |> List.choose id
        
    let nugetDependencies =
        cleanNugetDependencies
            ([ paketDependencies.groups |> List.map(fun x -> x.nugetDependencies ) |> List.concat
               nugetDependencies ]
             |> List.concat) 
        |> Async.Parallel
        |> Async.RunSynchronously
        
    outputDependencies nugetDependencies paketDependencies
    0

[<EntryPoint>]
let main argv =
    use consoleTrace = dotnet2nix.Logging.event.Publish |> Observable.subscribe dotnet2nix.Logging.traceToConsole
    let parser = ArgumentParser.Create<CliArguments>(programName = "dotnet2nix")

    let parseResults = parser.Parse(argv, raiseOnUsage = false)
    Logging.verbose <- parseResults.Contains <@ Verbose @>
    if parseResults.IsUsageRequested then
        printfn "%s" (parser.PrintUsage())
        0
    else
        try
            run parseResults
        with
        | Fail message ->
            traceError message
            1
