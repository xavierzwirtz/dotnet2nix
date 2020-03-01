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
    sdk_3_1
    netcore_3_1
    sdk_2_1
    netcore_2_1
  ];
}
