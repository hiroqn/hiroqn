{ stdenv, fetchzip, writeScript }:
stdenv.mkDerivation rec {
  version = "2.9.0-4806a6dc"; # https://formulae.brew.sh/api/cask/github.json
  name = "github-desktop-${version}";
  src = fetchzip {
    url = "https://desktop.githubusercontent.com/releases/${version}/GitHubDesktop-x64.zip";
    sha256 = "sha256-s9IFagjMmNk83qnlqo9UBugmSGNRJ6Apg4DIPHYMLfA=";
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
