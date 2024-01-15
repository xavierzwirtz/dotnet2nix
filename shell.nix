{ pkgs ? import ./nix {}
, paket ? import ./paket-derivation {}
}:

pkgs.mkShell
  {
    buildInputs = [
      paket
      (pkgs.dotnetCombined)
    ];
  }
