{ pkgs ? import ../nix {}
, dotnetCombined ? pkgs.dotnetCombined
}:

pkgs.stdenv.mkDerivation {
  name = "paket-bootstrap";

  phases = [ "buildPhase" ];
  src = pkgs.fetchurl {
    url = "https://globalcdn.nuget.org/packages/paket.5.242.2.nupkg";
    sha256 = "1n0qvvjqipnny3g806rlgbyx08nlb3vqz7ajr093lw67alaykin1";
  };

  propagatedBuildInputs = with pkgs; [
    dotnetCombined
  ];

  buildInputs = with pkgs; [
    makeWrapper
    dotnetCombined
    unzip
  ];

  dontUnpack = true;
  buildPhase = ''
    mkdir -p $out/bin
    unzip $src
    cp -r tools/netcoreapp2.1/any/. $out/bin
    ls $out/bin
    makeWrapper \
      ${dotnetCombined}/bin/dotnet \
      $out/bin/paket \
      --add-flags "$out/bin/paket.dll"
  '';

  installPhase = false;
}
