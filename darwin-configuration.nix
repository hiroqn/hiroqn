{ config, ... }:
let
  source = import ./nix/sources.nix;
  nixpkgs = import source.nixpkgs {};
  desktop = nixpkgs.callPackage ./nix/github-desktop.nix {};
  blackhole = nixpkgs.callPackage ./nix/black-hole.nix {};
  in
{
  # for some build
  nixpkgs.config.allowUnfree = true;

  users.nix.configureBuildUsers = true;
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
  environment.darwinConfig = toString ./darwin-configuration.nix;
  # system config
  environment.systemPackages =
    [
      nixpkgs.alacritty
      nixpkgs.coreutils
      nixpkgs.emacs
      nixpkgs.exa
      nixpkgs.git
      nixpkgs.gnupg
      nixpkgs.gnumake
      nixpkgs.jq
      nixpkgs.niv
      nixpkgs.nix-prefetch-git
      nixpkgs.openssh
      nixpkgs.terminal-notifier
      nixpkgs.vim
      desktop
    ];
  environment.shells = [ nixpkgs.zsh nixpkgs.bash ];
  environment.variables.PAGER = "cat";
  environment.variables.EDITOR = "${nixpkgs.vim}/bin/vi";
  environment.variables.LANG = "en_US.UTF-8";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

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
  system.build.plug-ins = nixpkgs.buildEnv {
    name = "system-plug-ins";
    paths = [blackhole]; #config.environment.systemPackages;
    pathsToLink = "/Library/Audio/Plug-Ins";
  };
  system.activationScripts.postActivation.text = ''

    find -L /Library/Audio/Plug-Ins -type d -name "*.driver" -print0 | while IFS= read -rd "" l; do
      if [ -r "$l/.nixdrv" ]; then
        if [ "${ config.system.build.plug-ins }" != "$(cat $l/.nixdrv)" ]; then
          echo "deleting old driver $driver..." >&2
          rm -rf $l
        else
          echo "same drv $driver..." >&2
        fi
      fi
    done
    find -L ${ config.system.build.plug-ins } -type d -name "*.driver" -print0 | while IFS= read -rd "" l; do
      driver=''${l##${config.system.build.plug-ins}}

      if [ ! -d "$driver" ]; then
          echo "adding driver $driver..." >&2

          cp -r $l $driver 2>/dev/null || {
            echo "Could not copy $driver" >&2
          }
          echo "${ config.system.build.plug-ins }" > "$driver/.nixdrv"
      else
        echo "already exist $driver"
      fi
    done
  '';
  nix.maxJobs = 16;
  nix.package = nixpkgs.nix;
  nix.nixPath = [
    {
      darwin-config = "${config.environment.darwinConfig}";
      darwin = source.nix-darwin;
      nixpkgs = source.nixpkgs;
    }
    "/nix/var/nix/profiles/per-user/root/channels"
    "$HOME/.nix-defexpr/channels"
  ];
  nix.buildCores = 16;
  nixpkgs.overlays = [
    (self: super: {
      direnv = (import source.direnv { }).overrideAttrs (oldAttrs: rec {
        doCheck = false;
      });
    })
  ];
}
