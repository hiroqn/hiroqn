{ config, ... }:
let
  source = import ./nix/sources.nix;
  nixpkgs = import source.nixpkgs {};
  desktop = nixpkgs.callPackage ./nix/github-desktop.nix {};
  blackhole = nixpkgs.callPackage source.nix-BlackHole {};
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
  system.build.audio-plug-ins = nixpkgs.buildEnv {
    name = "system-plug-ins";
    paths = [ blackhole ];
    pathsToLink = "/Library/Audio/Plug-Ins/HAL";
  };
  system.activationScripts.postActivation.text = ''
    mkdir -p /Library/Audio/Plug-Ins/HAL
    plugins="${ config.system.build.audio-plug-ins }"
    find -L /Library/Audio/Plug-Ins/HAL -type d -name "*.driver" -print0 | while IFS= read -rd "" path; do
      if [ -e "$path/.managed-by-nix" ]; then
        # if driver manged by nix-darwin
        if [ -e "$plugins$path" ]; then
          if [ "$(readlink $plugins$path)" != "$(cat "$path/.managed-by-nix")" ];then
            rm -rf "$path"
            echo "driver will be replaced: $path"
          fi
        else
          rm -rf "$path"
          echo "driver will be unmanaged: $path"
        fi
      fi
    done
    find -L $plugins -type d -name "*.driver" -print0 | while IFS= read -rd "" path; do
      driver=''${path##$plugins}
      if [ ! -e "$driver" ];then
        cp -r $path $driver 2>/dev/null || {
          echo "Could not copy $path" >&2
        }
        echo "$(readlink $path)" > "$driver/.managed-by-nix"
        echo "driver $path copied"
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
