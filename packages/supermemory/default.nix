{
  lib,
  stdenvNoCC,
  fetchurl,
  nodejs,
  makeBinaryWrapper,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "supermemory";
  version = "5.1.2";

  src = fetchurl {
    url = "https://registry.npmjs.org/supermemory/-/supermemory-${finalAttrs.version}.tgz";
    hash = "sha256-QwuWkXJg9xTg/DB3Rzf2Ox7zKjzxBNdkXCeVb5VB3aw=";
  };

  sourceRoot = "package";

  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/supermemory
    cp -r . $out/lib/node_modules/supermemory
    makeWrapper ${lib.getExe nodejs} $out/bin/supermemory \
      --add-flags $out/lib/node_modules/supermemory/bin/cli.mjs

    runHook postInstall
  '';

  meta = {
    description = "Command line interface for the Supermemory API";
    homepage = "https://supermemory.ai";
    license = lib.licenses.asl20;
    mainProgram = "supermemory";
    platforms = lib.platforms.all;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
  };
})
