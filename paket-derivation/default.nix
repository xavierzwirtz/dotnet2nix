{ pkgs ? import ../nix {}
, dotnetCombined ? pkgs.dotnetCombined
}:

pkgs.stdenv.mkDerivation {
  name = "paket-bootstrap";

  phases = [ "buildPhase" ];
  src = pkgs.fetchurl {
    url = "https://globalcdn.nuget.org/packages/paket.8.0.3.nupkg";
    sha256 = "12xm100rg82p5fvkn63mmjc8i38q8yvk5327snwzqijlfh3k60n0";
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
    makeWrapper \
      ${dotnetCombined}/bin/dotnet \
      $out/bin/paket \
      --add-flags "$out/bin/paket.dll"
  '';

  installPhase = false;
}
