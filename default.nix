{ pkgs ? import ./nix {}
, paket ? import ./paket-derivation {}
, buildDotnetCorePackage ? pkgs.callPackage ./buildDotnetCorePackage.nix {}
}:

buildDotnetCorePackage {
  inherit paket;
  name = "dotnet2nix";
  dotnetPackage = pkgs.dotnetCombined;
  dotnetDependencies = pkgs.callPackage ./dotnet.lock.nix {};
  projectFile = ./dotnet2nix.fsproj;
  src =
    pkgs.lib.cleanSourceWith {
      filter = name: type:
        ! (
          name == ./paket-derivation
        );
      src = pkgs.gitignore.gitignoreSource ./.;
    };
  buildInputs = [ pkgs.makeWrapper ];
  buildPhase = ''
    dotnet build --no-restore --configuration Release
    mkdir -p $out/build
    mkdir -p $out/bin
    cp -r bin/Release/net8.0/. $out/build
    makeWrapper \
      ${pkgs.dotnetCombined}/bin/dotnet \
      $out/bin/dotnet2nix \
        --add-flags "$out/build/dotnet2nix.dll" \
        --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.nix ]}
  '';
  dontInstall = true;
}
