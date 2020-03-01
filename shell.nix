{ pkgs ? import ./nix {}
, paket ? import ./paket-derivation {}
}:

pkgs.mkShell
  {
    buildInputs = [
      paket
      (pkgs.dotnetCombined)
      (
        pkgs.runCommand "jetbrains-with-dotnet"
          {
            dotnet = pkgs.dotnetCombined;
            rider = pkgs.jetbrains.rider;
            buildInputs = [ pkgs.makeWrapper ];
          }
          ''
            mkdir -p "$out/bin"
            makeWrapper "$rider/bin/rider" "$out/bin/rider-with-dotnet" --prefix PATH : "$dotnet/bin"
          ''
      )
    ];
  }
