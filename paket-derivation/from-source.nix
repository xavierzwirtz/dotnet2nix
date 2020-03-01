{ pkgs ? import ../nix {}
, src ? import ./source.nix {}
, paket ? import ./bootstrap.nix {}
, buildDotnetPackage ? pkgs.callPackage ../buildDotnetPackage.nix {}
}:

buildDotnetPackage {
  name = "paket";
  inherit paket;
  dotnetPackage = pkgs.dotnetCombined;
  dotnetDependencies = pkgs.callPackage ./dotnet.lock.nix {};
  inherit src;
  buildInputs = [ pkgs.makeWrapper ];
  patchPhase = ''
    substituteInPlace \
      src/Paket.Core/Paket.Core.fsproj \
       --replace netstandard2.0 netstandard2.1
    substituteInPlace \
      src/Paket/Paket.fsproj \
       --replace netcoreapp2.1 netcoreapp3.1
  '';
  dotnetRestorePhase = ''
    dotnet restore --source nuget_packages src/Paket.Core/Paket.Core.fsproj
    dotnet restore --source nuget_packages src/Paket/Paket.fsproj
  '';
  buildPhase = ''
    dotnet build \
      --no-restore \
      --configuration Release \
      --framework netcoreapp3.1 \
      src/Paket/Paket.fsproj
    mkdir -p $out/bin
    cp -r src/Paket/bin/Release/netcoreapp3.1/. $out/bin
    makeWrapper \
      ${pkgs.dotnetCombined}/bin/dotnet \
      $out/bin/paket \
        --add-flags "$out/bin/paket.dll"
  '';
  dontInstall = true;
}
