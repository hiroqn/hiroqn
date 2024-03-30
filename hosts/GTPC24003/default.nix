{ pkgs, config, ... }:
{
  
  # for some build
  nixpkgs.config.allowUnfree = true;

  users.users.hiroqn.name = "hiroqn";
  users.users.hiroqn.home = "/Users/hiroqn";

  environment.loginShell = "${pkgs.zsh}/bin/zsh -l";
  environment.shells = [ pkgs.zsh pkgs.bash ];
  environment.variables.PAGER = "cat";
  environment.variables.EDITOR = "${pkgs.vim}/bin/vim";
  environment.variables.LANG = "en_US.UTF-8";

  home-manager = {
    users.hiroqn.imports = [
      ./home.nix
    ];
  };
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.zsh.enableBashCompletion = false;
  programs.zsh.enableCompletion = false;
  programs.zsh.promptInit = "";

  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableSSHSupport = true;
  nix.configureBuildUsers = true;
  nix.package = pkgs.nixUnstable;
  nix.settings.max-jobs = 16;
  nix.settings.cores = 16;
  nix.extraOptions = ''
    netrc-file = /etc/nix/netrc
    experimental-features = nix-command flakes
  '';
  nix.envVars = {
    NIX_CURL_FLAGS = "--netrc-file /etc/nix/netrc";
  };
  nix.settings.trusted-public-keys = [
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
  ];
  nix.settings.substituters = [
    "https://cache.iog.io"
  ];
  security.pam.enableSudoTouchIdAuth = true;
  # system
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
