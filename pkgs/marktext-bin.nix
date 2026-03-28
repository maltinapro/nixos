{ appimageTools, fetchurl, lib, marktext-src }:

let
  pname = "marktext";

  # Read version from the flake input's package.json — not hardcoded.
  # Update by changing the tag in flake.nix and running: nix flake update marktext-src
  version = (builtins.fromJSON (builtins.readFile "${marktext-src}/package.json")).version;

  src = fetchurl {
    url = "https://github.com/marktext/marktext/releases/download/v${version}/marktext-x86_64.AppImage";
    # When updating to a new version, replace this hash. Build once with
    # lib.fakeHash to get the correct hash from the error message.
    hash = "sha256-LiVVET4334MLo5WO/MzOcCCQexL9QWI2jP2Qau2mMLc=";
  };

  extracted = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    mkdir -p $out/share
    # Some AppImages lack usr/share; ignore missing path errors.
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
