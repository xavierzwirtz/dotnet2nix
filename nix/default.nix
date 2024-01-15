{ sources ? import ./sources.nix }:
with
{
  overlay = _: pkgs:
    {
      niv = import sources.niv {};
      gitignore = import sources.gitignore {};
    };
};
let
  nixpkgs =
    import sources.nixpkgs
      { overlays = [ overlay ]; config = {}; };
in
nixpkgs // {
  dotnetCombined = with nixpkgs.dotnetCorePackages; combinePackages [
    sdk_8_0
    runtime_8_0
  ];
}
