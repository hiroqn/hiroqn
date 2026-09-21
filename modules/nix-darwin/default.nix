{ ... }: {
  home-manager.backupFileExtension = "backup";
  home-manager.useGlobalPkgs = true;
  # DIRENV_CONFIG=/etc/direnv のため、log_filter はこちらが実体。
  programs.direnv.silent = true;
}
