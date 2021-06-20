{ stdenv, fetchFromGitHub, xcodebuild, darwin}:
let
  inherit (darwin.apple_sdk.frameworks) CoreAudio;
in
stdenv.mkDerivation rec {
  version = "v0.2.7";
  name = "BlackHole-${version}";
  src = fetchFromGitHub {
    owner = "ExistentialAudio";
    repo = "BlackHole";
    rev = "refs/tags/${version}";
    sha256 = "sha256:0rpj7d0k7q5nmwn07lq5v040di8fbr2h15rmgd4909djvjxnnb8d";
  };
  buildInputs = [
    xcodebuild
    CoreAudio
  ];
  buildPhase = ''
    xcodebuild build
  '';
  installPhase = ''
    mkdir -p $out/Library/Audio/Plug-Ins/HAL
    mv BlackHole-*/Build/Products/*/BlackHole.driver $out/Library/Audio/Plug-Ins/HAL/
  '';
}
