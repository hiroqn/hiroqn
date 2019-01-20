{ stdenv, fetchzip, writeScript }:
stdenv.mkDerivation rec {
  version = "1.6.0-a2c1bb8f";
  name = "github-desktop-${version}";
  src = fetchzip {
    url = "https://desktop.githubusercontent.com/releases/${version}/GitHubDesktop.zip";
    sha256 = "0yr3bbyhhbs5h4qiv9nkcr16nhi5albjz3x423fqqnaxp174ji70";
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
