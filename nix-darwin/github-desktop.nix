{ stdenv, fetchzip, writeScript }:
stdenv.mkDerivation rec {
  version = "1.6.5-b8b05c40";
  name = "github-desktop-${version}";
  src = fetchzip {
    url = "https://desktop.githubusercontent.com/releases/${version}/GitHubDesktop.zip";
    sha256 = "sha256:09k2b05a2acvidy9jvh55fw7px5a9ycgg72hc7g80y5r9whrwziz";
  };
  dontPatchELF = true;
  dontStrip = true;
  appName = "GitHub Desktop.app";
  wrapperElectron = writeScript "github" ''
    #!${stdenv.shell}
    CONTENTS="$out/Applications/${appName}/Contents"
    ELECTRON="$CONTENTS/MacOS/GitHub Desktop"
    CLI="$CONTENTS/Resources/app/out/cli.js"
    ELECTRON_RUN_AS_NODE=1 "$ELECTRON" "$CLI" "$@"
    exit $?
  '';
  installPhase = ''
    mkdir -p  $out/bin
    mkdir -p "$out/Applications/${appName}"
    cp -R $src/Contents "$out/Applications/${appName}/"

    cat << EOS > $out/bin/github
    #!${stdenv.shell}
    CONTENTS="$out/Applications/${appName}/Contents"
    ELECTRON="\$CONTENTS/MacOS/GitHub Desktop"
    CLI="\$CONTENTS/Resources/app/cli.js"
    ELECTRON_RUN_AS_NODE=1 "\$ELECTRON" "\$CLI" "\$@"
    exit \$?
    EOS
    chmod +x $out/bin/github
  '';
  postFixup = "";
}