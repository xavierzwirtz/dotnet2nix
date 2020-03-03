{ pkgs ? import ../nix {}
, paket ? import ./bootstrap.nix {}
, dotnet2nix ? import ../. { inherit paket; }
}:

pkgs.mkShell
  {
    buildInputs = [
      dotnet2nix
      pkgs.nix
      pkgs.dotnetCombined
      paket
    ];
  }
