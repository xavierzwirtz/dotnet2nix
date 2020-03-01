let
  pkgs = import ../nix {};
in
pkgs.callPackage ./source.nix {}
