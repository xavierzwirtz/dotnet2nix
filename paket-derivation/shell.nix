{ pkgs ? import ../nix {}
, dotnet2nix ? import ../. {}
, paket ? import ./. {}
}:

pkgs.mkShell
  {
    buildInputs = [
      dotnet2nix
      pkgs.dotnetCombined
      paket
    ];
  }
