{
  lib,
  stdenvNoCC,
  fetchurl,
}:

# nixpkgs の fx は JSON ビューアーなので、エージェントは配布元のバイナリを使う。
stdenvNoCC.mkDerivation rec {
  pname = "fx";
  version = "0.0.7";

  src = fetchurl {
    url = "https://releases.fx.sh/v${version}/fx-linux-x86_64.tar.gz";
    hash = "sha256-xXh+oEHTtVIexnXxraePMM8bEQIf/KxItJac9b62XEU=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm755 fx "$out/bin/fx"
    install -Dm644 LICENSE "$out/share/licenses/fx/LICENSE"
    install -Dm644 THIRD_PARTY_NOTICES.md \
      "$out/share/doc/fx/THIRD_PARTY_NOTICES.md"

    runHook postInstall
  '';

  meta = {
    description = "Tiny, open, embeddable native coding agent";
    homepage = "https://github.com/vercel-labs/fx";
    license = lib.licenses.asl20;
    mainProgram = "fx";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
