{ stdenv, lib, runCommand, buildEnv, vscode, which, writeScript
, vscodeExtensions ? [] }:

let

  wrappedPkgVersion = lib.getVersion vscode;
  wrappedPkgName = lib.removeSuffix "-${wrappedPkgVersion}" vscode.name;

  combinedExtensionsDrv = buildEnv {
    name = "${wrappedPkgName}-extensions-${wrappedPkgVersion}";
    paths = vscodeExtensions;
  };

in
runCommand "${wrappedPkgName}-with-extensions-${wrappedPkgVersion}" {
  buildInputs = [ vscode ];
  dontPatchELF = true;
  dontStrip = true;
  meta = vscode.meta;
} ''
  CONTENTS="$out/Applications/Code.app/Contents"
  mkdir -p $out/bin
  mkdir -p "$out/Applications/Code.app"
  cp -R "${vscode}/lib/vscode/Contents" $CONTENTS
  chmod -R +w $CONTENTS/MacOS/
  mv "$CONTENTS/MacOS/Electron" "$CONTENTS/MacOS/Electron.orig"

  ELECTRON="$CONTENTS/MacOS/Electron.orig"
  CLI="$CONTENTS/Resources/app/out/cli.js"

  cat << EOS > "$CONTENTS/MacOS/Electron"
  #!${stdenv.shell}
  ELECTRON_RUN_AS_NODE=1 "$ELECTRON" "$CLI" --extensions-dir "${combinedExtensionsDrv}/share/${wrappedPkgName}/extensions" "\$@"
  exit \$?
  EOS
  chmod +x "$CONTENTS/MacOS/Electron"
  ln -sT "$CONTENTS/MacOS/Electron" "$out/bin/code"
''
