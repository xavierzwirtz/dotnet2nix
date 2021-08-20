module dotnet2nix.Program
open Argu
open Logging
open Process
open System
open System.IO
open Newtonsoft.Json.Linq
open FSharp.Collections.ParallelSeq
open Paket
open Utils
open Paket

type CliArguments =
    | [<Unique>] LockFile of string
    | [<Unique>] Verbose
    | [<Unique>] Silent
    | [<Unique>] Project of string
    | [<Unique>] DisableDotnet
    | [<Unique>] Force
with
    interface IArgParserTemplate with
        member s.Usage =
            match s with
            | LockFile _ -> "lock file to write to. defaults to dotnet.lock.nix"
            | Verbose -> "enables verbose logging"
            | Silent -> "disables logging"
            | Project _ -> "project or solution file to run dotnet commands against"
            | DisableDotnet -> "disable getting required packages from dotnet cli"
            | Force -> "force pre-fetching of all resources, including resources already in lock file"

type FileOrUrl =
| File of string
| Url of string

type NuGetDependency =
    { name : string
      version : string
      source : FileOrUrl
    }

type Hashed<'t> =
    { value : 't
      hashType : string
      hash : string
    }
    
type MaybeHashedNuGetDependency =
| Hashed of Hashed<NuGetDependency>
| NotHashed of NuGetDependency

type GitHubDependency =
    { owner : string
      repo : string
      file : string
      commit : string
    }
    
type DependencyGroup =
    { group : Domain.GroupName option
      nugetDependencies : MaybeHashedNuGetDependency list
      githubDependencies : GitHubDependency list
    }
    
type PaketDependencies =
    { groups : DependencyGroup list
    }
    
type HashedPaketDependencies =
    { githubDependencies : list<string option * Hashed<GitHubDependency>>
    }
    
type CachedNixLockFile =
    { nugetDependencies : Map<(string * string), Hashed<NuGetDependency>>
      githubDependencies : Map<(GitHubDependency), Hashed<GitHubDependency>>
    }
type NixLockFile =
    { nugetDependencies : Hashed<NuGetDependency> list
      githubDependencies : list<string option * Hashed<GitHubDependency>>
    }

type LocalNuget =
    { root : string
      path : string
      cache : Cache option
    }
type Source =
| LocalNuGet of LocalNuget
| Other of PackageSources.PackageSource

let hashTypes = ["sha256"; "sha512"]

let retry message f =
    let count = 3
    let rec retry i = 
        if i = count then f()
        else
            try
                f()
            with
            | _ ->
                tracefn "%s, retrying %i of 3" message i
                retry (i + 1)
    retry 0
    
let retryAsync message f =
    let count = 3
    let rec retry i =
        async {
            if i = count then
                return! f()
            else
                try
                    return! f()
                with
                | _ ->
                    tracefn "%s, retrying %i of 3" message i
                    return! retry (i + 1)
        }
    retry 0
    
let execSuccessRetry fileName arguments =
    retryAsync
        (sprintf "'%s %s' failed" fileName (printArguments arguments))
        (fun () -> execSuccess fileName arguments)
    
let resolvePackageUrl (cachedNixLockFile : CachedNixLockFile) (packageName : Domain.PackageName) (version : SemVerInfo) (sources : Source list) transitive =
    let packageName' = packageName.Name.ToString().ToLower()
    let version' = version.Normalize().ToLower()
    
    async {
        match cachedNixLockFile.nugetDependencies |> Map.tryFind (packageName', version') with
        | Some x ->
            tracefn "using cached nuget package %s %s" x.value.name x.value.version
            return Some (Hashed x)
        | None ->
            tracefn "resolving %s %s" (packageName') (version')
            let force = true
                
            let localPackageSources = sources |> List.choose(fun x ->
                match x with
                | LocalNuGet(x) -> Some (x)
                | _ -> None)
            let nugetPackageSources = sources |> List.choose(fun x ->
                match x with
                | Other(x) -> Some(x)
                | LocalNuGet _ -> None)
            
            let getLocalPackageDetails () =
                printfn "getting local package details for %s" packageName'
                localPackageSources |> List.tryPick(fun source ->
                    printfn "getting local package details for %s, source %A" packageName' source
                    try
                        let path = normalizeLocalPath source.path
                        let di = getDirectoryInfoForLocalNuGetFeed path None source.root
                        let nupkg = NuGetLocal.findLocalPackage di.FullName packageName version
                        Some(nupkg)
                    with | ex -> None)
                
            let getNugetPackageDetails () =
                retryAsync
                    (sprintf "resolving package %s %s details failed" packageName' version')
                    (fun () ->
                        let x =
                            NuGet.GetPackageDetails
                                None
                                (Directory.GetCurrentDirectory())
                                force
                                (PackageResolver.GetPackageDetailsParameters.ofParams
                                    nugetPackageSources
                                    Constants.MainDependencyGroup
                                    packageName
                                    version)
                        tracefn "finish resolving %s %s" (packageName') (version')
                        x)
                                
            let getPackageDetails() =
                async {
                    let local = getLocalPackageDetails()
                    match local with
                    | Some (local) ->
                        return
                            { name = packageName'
                              version = version'
                              source = File local.FullName
                            }
                            |> NotHashed
                            |> Some
                    | None ->
                        let! nugetPackage = getNugetPackageDetails()
                        return
                            { name = packageName'
                              version = version'
                              source = Url nugetPackage.DownloadLink
                            }
                            |> NotHashed
                            |> Some   
                }
            if not transitive then
                return! getPackageDetails()
            else
                try
                    return! getPackageDetails()
                with
                | ex ->
                    if ex.Message.StartsWith("Couldn't get package details for package") then
                        return None
                    else
                        return raise ex
    }
    
let parseNugetDependencies root (cachedNixLockFile : CachedNixLockFile) (sources : PackageResolver.PackageResolution) =
    groupBySources sources
    |> Seq.map(fun (source, packages) ->
        packages
        |> Seq.map(fun (_, _, package) ->
            let source =
                match package.Source with
                | PackageSources.LocalNuGet (path, cache) ->
                    LocalNuGet {
                        root = root
                        path = path
                        cache = cache
                    }
                | _ -> Other package.Source
                        
            resolvePackageUrl cachedNixLockFile package.Name package.Version [source] false 
        ))
    |> Seq.concat
    |> Seq.toList
         
let parseRemoteFileDependencies (remoteFiles : ModuleResolver.ResolvedSourceFile list) =
    remoteFiles
    |> Seq.map(fun source ->
        match source.Origin with
        | ModuleResolver.GitHubLink ->
            { owner = source.Owner
              repo = source.Project
              commit = source.Commit
              file = source.Name }
        | _  -> fail (sprintf "unsupported remote file origin %A" source.Origin)
    )
    |> Seq.distinct
    |> Seq.toList
    
let getPaketDependencies cachedNixLockFile =
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
                        parseNugetDependencies lockFile.RootPath cachedNixLockFile group.Value.Resolution
                        |> Async.Parallel
                        |> Async.StartChild
                        
                    let githubDependencies =
                        parseRemoteFileDependencies group.Value.RemoteFiles    
                        
                    let! nugetDependencies = nugetDependencies
                        
                    let groupName =
                        if group.Key = Paket.Constants.MainDependencyGroup then None
                        else Some group.Key
                    return
                        { group = groupName
                          nugetDependencies = nugetDependencies |> List.ofArray |> List.choose id
                          githubDependencies = githubDependencies
                        }
                }
            )
            |> Async.Parallel
            |> Async.RunSynchronously
            |> Seq.toList
        { groups = groups }

let cleanAndHashPaketDependencies (cachedNixLockFile : CachedNixLockFile)  (paketDependencies : PaketDependencies) : HashedPaketDependencies =
    let prefetchGithub github =
        match cachedNixLockFile.githubDependencies |> Map.tryFind github with
        | Some x ->
            tracefn "using cached github %s %s" x.value.owner x.value.repo
            async { return x }
        | None ->
            async {
                tracefn "prefetching github %s %s" github.owner github.repo
                let! hashResp =
                    execSuccessRetry "nix-prefetch-github" [
                        github.owner; github.repo; "--rev"; github.commit ]
                tracefn "finish prefetching github %s %s" github.owner github.repo
                let hashResp = hashResp.output |> JObject.Parse
                let hashType = "sha256"
                let hash = hashResp.Item(hashType).ToObject<string>()
                                    
                return
                    { value = github
                      hash = hash
                      hashType = hashType
                    }
            }
    let githubDependencies =
        paketDependencies.groups
        |> List.map(fun group ->
            group.githubDependencies
            |> List.map(fun github ->
                let groupName =
                    group.group
                    |> Option.map(fun x -> x.ToString().ToLower())
                (groupName, github)))
        |> List.concat
        |> List.groupBy(fun (_, github) -> github)
        |> Seq.map(fun (github, groups) ->
            async {
                let! prefetched = prefetchGithub github
                return groups |> List.map(fun (group, _) -> group, prefetched)
            })
        |> Async.Parallel
        |> Async.RunSynchronously
        |> List.ofArray
        |> List.concat
        |> List.sort
    { githubDependencies = githubDependencies }
        
type DotNetParseState =
| NotStarted
| InProject
| TopLevelPackages of int * int
| TransitivePackages of int

let topLevelPackagesRe =
    System.Text.RegularExpressions.Regex("(?<name>Top-level Package) +(?<requested>Requested) +(?<resolved>Resolved)")
let transitivePackagesRe =
    System.Text.RegularExpressions.Regex("(?<name>Transitive Package) +(?<resolved>Resolved)")
let getNugetDependencies (paketDependencies : PaketDependencies) cachedNixLockFile nugetSources project =
    tracefn "parsing 'dotnet list package'"
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
        
        let paketDep =
            let name = name.ToLower()
            let version = version.ToLower()
            paketDependencies.groups |> List.tryPick(fun group ->
                group.nugetDependencies
                |> List.tryPick(fun nugetDependency ->
                    let check x =
                        //tracefn "x.name(%s) = name(%s) && x.version(%s) = version(%s) " x.name name x.version version 
                        if x.name = name &&
                           x.version = version then
                           Some(nugetDependency)
                        else None
                    match nugetDependency with
                    | Hashed(hashed) -> check(hashed.value)
                    | NotHashed(x) -> check(x)
                    ) )
        match paketDep with
        | Some(x) -> async { return Some x }
        | None -> 
            resolvePackageUrl
                cachedNixLockFile
                (Domain.PackageName(name))
                (SemVer.Parse version)
                nugetSources
                transative)
    |> Async.Parallel
    |> Async.RunSynchronously
    |> List.ofArray
    
let cleanAndHashNugetDependencies (dependencies : MaybeHashedNuGetDependency list) =
    async {
        let (hashed, unhashed) =
            dependencies
            |> List.map(fun x ->
                match x with
                | Hashed x -> Choice1Of2(x)
                | NotHashed x -> Choice2Of2(x))
            |> List.partitionChoice
        
        let! unhashedNowHashed =
            unhashed
            |> List.groupBy (fun x ->
                x.name, x.version)
            |> List.map(fun ((name,version), grouped) ->
                async {
                    let hd = grouped |> List.head
                    let hashType = "sha256"

                    let! hashRaw = 
                        match hd.source with
                        | Url url ->
                            async {
                                tracefn "pre-fetching %s" url
                                let! hashRaw =
                                    execSuccessRetry
                                        "nix-prefetch-url" [
                                            url; "--type"; hashType ]
                                tracefn "finish pre-fetching %s" url
                                return hashRaw   
                            }
                        | File file ->
                            async {
                                tracefn "hashing %s" file
                                let! hashRaw =
                                    execSuccessRetry
                                        "nix-hash" [
                                            "--base32"; "--type"; hashType; file ]
                                tracefn "finish hashing %s" file
                                return hashRaw   
                            }
                    
                    let hash = hashRaw.output.Trim('\r', '\n')
                    
                    return
                        { value = hd
                          hashType = hashType
                          hash = hash
                        }
                })
            |> Async.Parallel
        let sorted =
            hashed @ (unhashedNowHashed |> List.ofArray)
            |> List.groupBy (fun x ->
                x.value.name, x.value.version)
            |> List.map(fun ((name,version), grouped) -> grouped |> List.head)
            |> List.sortBy(fun x -> x.value.name + "-" + x.value.version)
        return sorted
    }  |> Async.RunSynchronously

let printNuGetDependency lockFileDir (nuget : Hashed<NuGetDependency>) =
    sprintf """    (
      fetchNuGet {
        name = "%s";
        version = "%s";
        %s;
        %s = "%s";
      }
    )"""
            nuget.value.name 
            nuget.value.version 
            (
                match nuget.value.source with
                | Url x -> sprintf "url = \"%s\"" x
                | File x -> sprintf "file = \"%s\"" (Path.GetRelativePath(lockFileDir, x))
            ) 
            nuget.hashType
            nuget.hash
            
let printGitHubDependency
    (group : string option)
    (github : Hashed<GitHubDependency>) =
    sprintf """    (
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
             | Some (x) -> "\"" + x + "\"")
            github.value.owner
            github.value.repo 
            github.value.commit
            github.value.file
            github.hashType 
            github.hash
            
let outputDependencies lockFile builtLockFile =
    let lockFile = Path.GetFullPath(lockFile)
    traceVerbose (sprintf "built lock file: %A" builtLockFile)
    use writer = IO.File.Create(lockFile)
    use textWriter = new IO.StreamWriter(writer)
     
    textWriter.WriteLine """{ fetchurl
, fetchFromGitHub
, stdenv
, lib
, unzip
, dotnet2nix-fetchNuGet ? (
    { name, version, ... } @ attrs:
      stdenv.mkDerivation {
        name = name;
        pversion = version;
        phases = [ "buildPhase" ];
        src =
          if attrs ? url then
            fetchurl (
              (
                builtins.removeAttrs attrs [
                  "version"
                ]
              ) // {
                inherit name;
              }
            )
          else
            builtins.path {
              path = ./. + ("/" + attrs.file);
              sha256 = attrs.sha256;
            };
        dontUnpack = true;
        buildPhase = ''
          mkdir -p "$out"
          cp $src "$out/${lib.strings.toLower name}.${lib.strings.toLower version}.nupkg"
        '';
      }
  )
, dotnet2nix-fetchFromGitHubForPaket ? (
    { group, owner, repo, rev, file, ... } @ attrs:
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
        }
  )
}:
let
  fetchNuGet = dotnet2nix-fetchNuGet;
  fetchFromGitHubForPaket = dotnet2nix-fetchFromGitHubForPaket;
in
{
  nuget = ["""
    for nuget in builtLockFile.nugetDependencies do
        textWriter.WriteLine(printNuGetDependency (Path.GetDirectoryName(lockFile)) nuget)
        
    textWriter.WriteLine """  ];
  github = ["""
    for (group, github) in builtLockFile.githubDependencies do
        textWriter.WriteLine(printGitHubDependency group github)
    textWriter.WriteLine """  ];
}"""
    
let getNugetSources () =
    // TODO this should look for a NuGet.Config and parse the data from it
    // use list of sources from paket.dependencies if availible
    [ Other (PackageSources.PackageSource.Parse "nuget https://api.nuget.org/v3/index.json") ]

let getCachedNixLockFile force lockFile : CachedNixLockFile =
    if force || File.Exists lockFile |> not then
        { nugetDependencies = Map.empty
          githubDependencies = Map.empty
        }
    else
        let result =
            exec "nix"
                ["eval"; "(import ./" + lockFile + " {
                    fetchurl = null;
                    fetchFromGitHub = null;
                    stdenv = null;
                    lib = null;
                    unzip = null;
                    dotnet2nix-fetchNuGet = x :
                        if x ? url then x
                        else
                            if builtins.typeOf x.file == ''path'' then
                                throw ''file attr with type path is unsupported''
                            else x;
                    dotnet2nix-fetchFromGitHubForPaket = x : x;
                })"; "--json"]
            |> Async.RunSynchronously
        if result.exitCode <> 0 then
            printfn "%s" result.error
            fail (sprintf "error processing %s, rerun with --force to ignore" lockFile)
        else
            let j = JObject.Parse(result.output)
            
            let tryGetHashType (x : JToken) =
                hashTypes |> Seq.tryPick(fun hashType ->
                    let y = x.Item(hashType)
                    if y = null then None
                    else Some(hashType, y.ToObject<string>()))
                
            let github =
                j.Item("github") :?> JArray
                |> Seq.choose(fun (x : JToken) ->
                    let s (n : string) = x.Item(n).ToObject<string>()
                    let owner = s "owner"
                    let repo = s "repo"
                    let rev = s "rev"
                    let file = s "file"
                    let hashType_hash = tryGetHashType x
                    match hashType_hash with
                    | None ->
                        tracef
                            "could not parse hash on github dependency owner: '%s', repo '%s', rev: '%s', file: '%s'"
                            owner
                            repo
                            rev
                            file
                        None
                    | Some (hashType, hash) ->
                        let v = { owner = owner
                                  repo = repo
                                  commit = rev
                                  file = file
                                }
                        (v, { value = v
                              hashType = hashType
                              hash = hash })
                        |> Some)
                |> Map.ofSeq
                
            let nuget =
                j.Item("nuget") :?> JArray
                |> Seq.choose(fun (x : JToken) ->
                    let x = x :?> JObject
                    let s (n : string) = x.Item(n).ToObject<string>()
                    let name = (s "name").ToLower()
                    let version = s "version"
                    let hashType_hash = tryGetHashType x
                    let source =
                        if x.ContainsKey("url") then
                            Some (Url (s "url"))
                        else if x.ContainsKey("file") then
                            let file = s "file"
                            let file = Path.GetFullPath(file, Path.GetDirectoryName (Path.GetFullPath(lockFile)))
                            Some (File (file))
                        else
                            None
                    
                    match hashType_hash with
                    | None ->
                        tracef
                            "could not parse hash on nuget dependency, name: '%s', version '%s'"
                            name
                            version
                        None
                    | Some (hashType, hash) ->
                        match source with
                        | None ->
                            tracef
                                "could not parse source on nuget dependency, name: '%s', version '%s'"
                                name
                                version
                            None
                        | Some source ->
                            ((name, version),
                             { value = { name = name
                                         version = version
                                         source = source
                                        }
                               hashType = hashType
                               hash = hash
                             }) |> Some)
                |> Map.ofSeq
                
            { nugetDependencies = nuget
              githubDependencies = github
            }
 
let buildLockFile nugetDependencies (paketDependencies : HashedPaketDependencies) =
    { nugetDependencies = nugetDependencies
      githubDependencies = paketDependencies.githubDependencies
    }
    
let run (parserResults : ParseResults<CliArguments>) =
    
    let project = parserResults.TryGetResult <@ Project @>
    let lockFile = parserResults.TryGetResult <@ LockFile @> |> Option.defaultValue "dotnet.lock.nix"
    let disableDotnet = parserResults.Contains <@ DisableDotnet @>
    let force = parserResults.Contains <@ Force @>

    let cachedNixLockFile = getCachedNixLockFile force lockFile
    let paketDependencies = getPaketDependencies cachedNixLockFile
    let nugetDependencies =
        if disableDotnet then []
        else 
            let nugetSources = getNugetSources () // TODO merge this with paket sources
            getNugetDependencies paketDependencies cachedNixLockFile nugetSources project |> List.choose id
    let hashedPaketDependencies = cleanAndHashPaketDependencies cachedNixLockFile paketDependencies
    
    let nugetDependencies =
        cleanAndHashNugetDependencies
            ([ paketDependencies.groups |> List.map(fun x -> x.nugetDependencies ) |> List.concat
               nugetDependencies ]
             |> List.concat)
        
    let builtLockFile = buildLockFile nugetDependencies hashedPaketDependencies 
    outputDependencies lockFile builtLockFile
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
