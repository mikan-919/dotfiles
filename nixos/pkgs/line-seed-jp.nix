{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation {
  pname = "line-seed-jp";
  version = "2024-11-05";

  src = fetchurl {
    url = "https://seed.line.me/src/images/fonts/LINE_Seed_JP.zip";
    hash = "sha256-dcAUTLEHbqH+XJvwgTljM9QLbUtmxfgSYE6sLAh/T0g=";
  };

  nativeBuildInputs = [ unzip ];
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 Desktop/OTF/*.otf -t "$out/share/fonts/opentype"
    install -Dm644 OFL.txt "$out/share/licenses/line-seed-jp/OFL.txt"

    runHook postInstall
  '';

  meta = {
    description = "LINE Seed Japanese typeface";
    homepage = "https://seed.line.me/index_jp.html";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
}
