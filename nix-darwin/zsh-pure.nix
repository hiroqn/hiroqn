{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  version = "v1.12.0";
  name = "pure-${version}";

  src = fetchFromGitHub {
    owner = "sindresorhus";
    repo = "pure";
    rev = version;
    sha256 = "1h04z7rxmca75sxdfjgmiyf1b5z2byfn6k4srls211l0wnva2r5y";
  };

  installPhase = ''
    mkdir -p $out/share/zsh/site-functions/
    cp pure.zsh $out/share/zsh/site-functions/prompt_pure_setup
    cp async.zsh $out/share/zsh/site-functions/async
  '';
}
