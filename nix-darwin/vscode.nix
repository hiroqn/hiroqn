{ stdenv, lib, runCommand, buildEnv, vscode, makeWrapper
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
  buildInputs = [ vscode makeWrapper ];
  dontPatchELF = true;
  dontStrip = true;
  meta = vscode.meta;
} ''
  CONTENT="Applications/Visual Studio Code.app/Contents"
  mkdir -p $out/bin
  mkdir -p "$out/$CONTENT"
  mkdir -p "$out/$CONTENT/MacOS"

  for key in "Frameworks" "Info.plist" "PkgInfo" "Resources" "_CodeSignature"; do
    ln -s "${vscode}/$CONTENT/$key" "$out/$CONTENT/$key"
  done

  makeWrapper "${vscode}/$CONTENT/MacOS/Electron" "$out/$CONTENT/MacOS/Electron" \
    --add-flags "\"$out/$CONTENT/Resources/app/out/cli.js\"" \
    --add-flags "--extensions-dir ${combinedExtensionsDrv}/share/${wrappedPkgName}/extensions" \
    --set ELECTRON_RUN_AS_NODE 1

  ln -s "$out/$CONTENT/MacOS/Electron" "$out/bin/code"
''
