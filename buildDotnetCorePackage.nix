{ pkgs ? import ./nix {} }:

{ dotnetPackage
, dotnetDependencies ? {}
, paket ? import ./paket-derivation {}
, name
, src
, buildInputs ? []
, propagatedBuildInputs ? []
, buildPhase ? ''
    dotnet build --no-restore
  ''
, dotnetRestorePhase ? ''
    dotnet restore --source nuget_packages
  ''
, ...
} @ attrs:

pkgs.stdenv.mkDerivation (
  builtins.removeAttrs attrs [
    "dotnetDependencies"
    "dotnetPackage"
    "paket"
  ] // {
    inherit name src buildPhase dotnetRestorePhase;
    buildInputs = [
      paket
    ] ++ buildInputs;
    propagatedBuildInputs = [
      dotnetPackage
    ] ++ propagatedBuildInputs;

    preBuildPhases = [ "restorePackagesPhase" "dotnetRestorePhase" ];
    restorePackagesPhase = ''
      # prevent paket copy included in repo from being used
      rm -f .paket/paket.exe .paket/paket.bootstrapper.exe
      mkdir -p nuget_packages
      export HOME="$(pwd)/home"
      for package in ${toString dotnetDependencies.nuget}; do
        cp -r $package/. nuget_packages
      done

      mkdir -p paket-files
      echo ${toString dotnetDependencies.github}
      for github in ${toString dotnetDependencies.github}; do
        cp --no-preserve all -r "$github/." paket-files/
      done

      paket_dependencies=$(\
        cat paket.dependencies | \
        sed -r 's/^(\s*)source.*$/\0\n\1cache .\/nuget_packages versions: current/g')
      rm paket.dependencies
      printf "%s" "$paket_dependencies" > paket.dependencies
      paket restore
    '';

    dontStrip = true;
  }
)
