{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  version = "v1.8.0";
  name = "pure-${version}";

  src = fetchFromGitHub {
    owner = "sindresorhus";
    repo = "pure";
    rev = version;
    sha256 = "04w9xsga1vxfz56c4xwb1lx7yziz61yk6g4rn42j6y1drijfdr71";
  };

  installPhase = ''
    mkdir -p $out/share/zsh/site-functions/
    cp pure.zsh $out/share/zsh/site-functions/prompt_pure_setup
    cp async.zsh $out/share/zsh/site-functions/async
  '';
}
