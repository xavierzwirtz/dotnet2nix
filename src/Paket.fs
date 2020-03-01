module dotnet2nix.Paket
open System
open System.IO
open Paket
open Paket.Domain
open Paket.Git.Handling
open Paket.Logging
open Paket.PackageResolver
open Paket.ModuleResolver
open Paket.PackageSources
open Paket.Requirements

/// [omit]
let groupBySources (resolved : PackageResolver.PackageResolution) =
    resolved
        |> Seq.map (fun kv ->
                let package = kv.Value
                match package.Source with
                | NuGetV2 source -> source.Url,source.Authentication,package
                | NuGetV3 source -> source.Url,source.Authentication,package
                | LocalNuGet(path,_) -> path,AuthService.GetGlobalAuthenticationProvider path,package
            )
        |> Seq.groupBy (fun (a,b,_) -> a)