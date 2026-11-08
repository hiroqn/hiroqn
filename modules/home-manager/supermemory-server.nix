{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.supermemory-server;
  envFile = "${config.home.homeDirectory}/.supermemory/env";
  start = pkgs.writeShellScript "supermemory-server-launchd" ''
    set -a
    if [[ -f ${lib.escapeShellArg envFile} ]]; then
      source ${lib.escapeShellArg envFile}
    fi
    set +a
    exec ${lib.getExe cfg.package} "$@"
  '';
in
{
  options.services.supermemory-server = {
    enable = lib.mkEnableOption "Supermemory server";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../../packages/supermemory-server { };
      defaultText = lib.literalExpression "pkgs.callPackage ../../packages/supermemory-server { }";
      description = "Package providing the supermemory-server binary.";
    };

    logFile = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.stateHome}/supermemory/server.log";
      defaultText = lib.literalExpression "\"\${config.xdg.stateHome}/supermemory/server.log\"";
      description = "Combined stdout and stderr log for the daemon.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.activation.supermemoryServerPrepare = lib.hm.dag.entryBefore [ "setupLaunchAgents" ] ''
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg (builtins.dirOf cfg.logFile)}

      # The installer LaunchAgent uses another label and would keep port 6767.
      legacyLabel=ai.supermemory.server
      legacyPlist="$HOME/Library/LaunchAgents/$legacyLabel.plist"
      $DRY_RUN_CMD /bin/launchctl bootout "gui/$(${pkgs.coreutils}/bin/id -u)/$legacyLabel" || true
      if [[ -e "$legacyPlist" && ! -L "$legacyPlist" ]]; then
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/rm -f "$legacyPlist"
      fi
    '';

    launchd.agents.supermemory-server = {
      enable = true;
      config = {
        ProgramArguments = [ "${start}" ];
        WorkingDirectory = config.home.homeDirectory;
        KeepAlive = true;
        RunAtLoad = true;
        ProcessType = "Background";
        StandardOutPath = cfg.logFile;
        StandardErrorPath = cfg.logFile;
      };
    };
  };
}
