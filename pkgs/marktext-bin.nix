{ appimageTools, fetchurl, lib }:

let
  pname = "marktext";
  version = "0.17.1";

  src = fetchurl {
    url = "https://github.com/marktext/marktext/releases/download/v${version}/marktext-x86_64.AppImage";
    hash = "sha256-LiVVET4334MLo5WO/MzOcCCQexL9QWI2jP2Qau2mMLc=";
  };

  extracted = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    mkdir -p $out/share
    cp -r ${extracted}/usr/share/* $out/share/ 2>/dev/null || true
    # Fix desktop file to use the wrapper binary name
    if [ -f $out/share/applications/marktext.desktop ]; then
      substituteInPlace $out/share/applications/marktext.desktop \
        --replace-warn "Exec=AppRun" "Exec=marktext"
    fi
  '';

  meta = with lib; {
    description = "Simple and elegant markdown editor, available for Linux, macOS and Windows";
    homepage = "https://www.marktext.cc";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "marktext";
  };
}
