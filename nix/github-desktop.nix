{ stdenv, fetchzip, writeScript }:
stdenv.mkDerivation rec {
  version = "2.5.2-41e70ee4";
  name = "github-desktop-${version}";
  src = fetchzip {
    url = "https://desktop.githubusercontent.com/releases/${version}/GitHubDesktop.zip";
    sha256 = "sha256:0aij1cxd0659wn1ss67wi0m0fvwspn6cv6sn39p970bb859djaiv";
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
    chmod -R 777 "$out/Applications/${appName}/Contents/Resources/app/"
    sed -i -e 's/\.checkForUpdates()//' "$out/Applications/${appName}/Contents/Resources/app/renderer.js"
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
