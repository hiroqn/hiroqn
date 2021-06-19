{ config, ... }:
let
  source = import ./nix/sources.nix;
  nixpkgs = import source.nixpkgs {};
  desktop = nixpkgs.callPackage ./nix/github-desktop.nix {};
  in
{
  # for some build
  nixpkgs.config.allowUnfree = true;

  users.users.hiroqn.name = "hiroqn";
  users.users.hiroqn.home = "/Users/hiroqn";

  # home-manager
  imports = [
    "${source.home-manager}/nix-darwin"
  ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.hiroqn = import ./home.nix;
  };
  # system config
  fonts.enableFontDir = true;
  fonts.fonts = [ nixpkgs.monoid ];
  environment.systemPackages =
    [
      (import source.niv {}).niv
      nixpkgs.coreutils
      nixpkgs.openssh
      nixpkgs.vim
      nixpkgs.emacs
      nixpkgs.git
      nixpkgs.fzf
      nixpkgs.gnupg
      nixpkgs.alacritty
      nixpkgs.gnumake
      nixpkgs.jq
      nixpkgs.nix-prefetch-git
      nixpkgs.exa
      nixpkgs.terminal-notifier
      desktop
      nixpkgs.pure-prompt
      (nixpkgs.callPackage ./nix/black-hole.nix {})
    ];
  environment.shells = [ nixpkgs.zsh nixpkgs.bash ];
  environment.variables.PURE_GIT_PULL = "0";
  environment.variables.PAGER = "cat";
  environment.variables.EDITOR = "${nixpkgs.vim}/bin/vi";
  environment.variables.LANG = "en_US.UTF-8";

  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 25;
  system.defaults.NSGlobalDomain.KeyRepeat = 3;
  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
  system.defaults.trackpad.Clicking = true;
  system.defaults.dock.autohide = false;
  system.defaults.dock.orientation = "left";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.enableFzfHistory = true;
  programs.zsh.enableFzfGit = true;
  programs.zsh.enableFzfCompletion = true;
  # pure maybe fuck
  programs.zsh.promptInit = "autoload -U promptinit && promptinit && prompt pure";
  programs.zsh.interactiveShellInit = ''
    export FPATH
  '';
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableSSHSupport = true;
  programs.tmux.enable = true;
  programs.tmux.enableSensible = true;
  programs.tmux.enableMouse = true;
  programs.tmux.enableFzf = true;
  programs.tmux.enableVim = true;

  programs.tmux.extraConfig = ''
    unbind C-b
    set -g prefix C-j
    bind-key C-j send-prefix
    #   bind 0 set status
    #   bind S choose-session
    #   bind-key -r "<" swap-window -t -1
    #   bind-key -r ">" swap-window -t +1
    #   bind-key -n M-r run "tmux send-keys -t .+ C-l Up Enter"
    #   bind-key -n M-t run "tmux send-keys -t _ C-l Up Enter"
    set -g pane-active-border-style fg=black
    set -g pane-border-style fg=black
    set -g status-bg black
    set -g status-fg white
    set -g status-right '#[fg=white]#(id -un)@#(hostname)   #(cat /run/current-system/darwin-version)'
  '';
  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  networking.hostName = "brahman";
  nix.maxJobs = 16;
  nix.buildCores = 16;
  nix.package = nixpkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nixpkgs.overlays = [
    (self: super: {
      direnv = (import source.direnv { }).overrideAttrs (oldAttrs: rec {
        doCheck = false;
      });
    })
  ];
}
