{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.services.lore-server;
  tomlFormat = pkgs.formats.toml { };

  settings = lib.recursiveUpdate {
    server.quic.certificate = {
      cert_file = "${cfg.certDir}/cert.pem";
      pkey_file = "${cfg.certDir}/key.pem";
    };
    immutable_store.local = {
      path = cfg.dataDir;
      flush_delay_seconds = 10;
    };
    mutable_store.local = {
      path = cfg.dataDir;
      flush_delay_seconds = 10;
    };
  } cfg.settings;

  configDir = pkgs.runCommand "lore-server-config" { } ''
    mkdir -p $out
    cp ${tomlFormat.generate "local.toml" settings} $out/local.toml
  '';
in
{
  options.services.lore-server = {
    enable = lib.mkEnableOption "Lore Server daemon";

    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.hiroqn.packages.${pkgs.stdenv.hostPlatform.system}.lore;
      defaultText = lib.literalExpression "inputs.hiroqn.packages.\${system}.lore";
      description = "The lore package providing the loreserver binary.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.dataHome}/lore/server/store";
      defaultText = lib.literalExpression "\"\${config.xdg.dataHome}/lore/server/store\"";
      description = "Persistent directory for the mutable and immutable stores.";
    };

    certDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.dataHome}/lore/server/certs";
      defaultText = lib.literalExpression "\"\${config.xdg.dataHome}/lore/server/certs\"";
      description = ''
        Directory holding the QUIC certificate (cert.pem/key.pem). A self-signed
        certificate valid for localhost is generated on activation if missing.
      '';
    };

    logFile = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.stateHome}/lore/server.log";
      defaultText = lib.literalExpression "\"\${config.xdg.stateHome}/lore/server.log\"";
      description = "Combined stdout/stderr log file for the daemon.";
    };

    settings = lib.mkOption {
      type = tomlFormat.type;
      default = { };
      description = ''
        Extra loreserver settings, deep-merged over the defaults and rendered to
        local.toml. See the Lore Server config reference.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.activation.loreServerSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "${cfg.dataDir}" "${cfg.certDir}"
      if [ ! -e "${cfg.certDir}/cert.pem" ] || [ ! -e "${cfg.certDir}/key.pem" ]; then
        $DRY_RUN_CMD ${lib.getExe' pkgs.openssl "openssl"} req -x509 -newkey rsa:2048 -nodes \
          -keyout "${cfg.certDir}/key.pem" \
          -out "${cfg.certDir}/cert.pem" \
          -days 3650 -subj "/CN=localhost" \
          -addext "subjectAltName=IP:127.0.0.1,IP:::1,DNS:localhost"
      fi
    '';

    launchd.agents.lore-server = {
      enable = true;
      config = {
        ProgramArguments = [
          (lib.getExe' cfg.package "loreserver")
          "--config"
          "${configDir}"
        ];
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = cfg.logFile;
        StandardErrorPath = cfg.logFile;
      };
    };
  };
}
