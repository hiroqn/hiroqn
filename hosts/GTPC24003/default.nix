{ pkgs, config, ... }:
{
  users.users.hiroqn.name = "hiroqn";
  users.users.hiroqn.home = "/Users/hiroqn";

  environment.shells = [ pkgs.zsh pkgs.bash ];
  environment.variables.PAGER = "cat";
  environment.variables.EDITOR = "${pkgs.vim}/bin/vim";
  environment.variables.LANG = "en_US.UTF-8";

  home-manager = {
    users.hiroqn.imports = [
      ./home.nix
    ];
  };

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.zsh.enableBashCompletion = false;
  programs.zsh.enableCompletion = false;
  programs.zsh.promptInit = "";

  # m3 mac
  nix.settings.max-jobs = 8;
  nix.settings.cores = 8;

  security.pam.services.sudo_local.touchIdAuth = true;
}
