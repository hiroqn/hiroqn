{
  lib,
  stdenvNoCC,
  fetchurl,
  versionCheckHook,
}:
let
  # The server source is private. These are the published release binaries.
  sources = {
    aarch64-darwin = {
      url = "https://github.com/supermemoryai/supermemory/releases/download/server-v${version}/supermemory-server-darwin-arm64";
      hash = "sha256-uQgIAnDfbS61cSY3y4M+vU/Jmm7hV3HTilVQhJYTMug=";
    };
    x86_64-darwin = {
      url = "https://github.com/supermemoryai/supermemory/releases/download/server-v${version}/supermemory-server-darwin-x64";
      hash = "sha256-web2DdzuJD3s4z2IiPScPa80AUKeifFrnRsM3Sv0A6M=";
    };
    aarch64-linux = {
      url = "https://github.com/supermemoryai/supermemory/releases/download/server-v${version}/supermemory-server-linux-arm64";
      hash = "sha256-t4m+Fs1xkrPAjogjlsCpS6Mw6kZ9Wn+xs5rDaEq/U3Q=";
    };
    x86_64-linux = {
      url = "https://github.com/supermemoryai/supermemory/releases/download/server-v${version}/supermemory-server-linux-x64";
      hash = "sha256-15h+y/KwJMbenRZ77Lz8qrzkRxabQdb1bbhvh9UYeYQ=";
    };
  };
  version = "0.0.9";
in
stdenvNoCC.mkDerivation {
  pname = "supermemory-server";
  inherit version;

  src = fetchurl sources.${stdenvNoCC.hostPlatform.system};

  dontUnpack = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/supermemory-server
    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  versionCheckProgramArg = "version";

  meta = {
    description = "Self-hosted Supermemory server";
    homepage = "https://supermemory.ai/docs/self-hosting/quickstart";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "supermemory-server";
    platforms = builtins.attrNames sources;
  };
}
