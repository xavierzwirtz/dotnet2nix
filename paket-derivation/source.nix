{ pkgs ? import ../nix {} }:

pkgs.fetchFromGitHub {
  owner = "xavierzwirtz";
  repo = "Paket";
  rev = "netstandard2.1-compat";
  sha256 = "1z2l1p4w338qdrjl8hr00a7bd7dzmvv9mfyp22yd3k4lrh22gms0";
}
