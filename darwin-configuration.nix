{ pkgs, config, ... }:
let
  desktop = pkgs.callPackage ./nix/github-desktop.nix { };
in
{
  # for some build
  nixpkgs.config.allowUnfree = true;

  users.nix.configureBuildUsers = true;
  users.users.hiroqn.name = "hiroqn";
  users.users.hiroqn.home = "/Users/hiroqn";

  # home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.hiroqn = import ./home.nix;
  };
  environment.darwinConfig = toString ./darwin-configuration.nix;
  # system config
  environment.systemPackages =
    [
      pkgs.alacritty
      pkgs.coreutils
      pkgs.emacs
      pkgs.exa
      pkgs.gnupg
      pkgs.gnumake
      pkgs.jq
      pkgs.nix-prefetch-git
      pkgs.openssh
      pkgs.terminal-notifier
      pkgs.vim
      desktop
    ];
  environment.shells = [ pkgs.zsh pkgs.bash ];
  environment.variables.PAGER = "cat";
  environment.variables.EDITOR = "${pkgs.vim}/bin/vim";
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

  networking.hostName = "veda-20210910";
  networking.computerName = "veda-20210910";
  system.build.audio-plug-ins = pkgs.buildEnv {
    name = "system-plug-ins";
    paths = [ pkgs.blackhole ];
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
  nix.buildCores = 16;
  nix.extraOptions = ''
    netrc-file = /etc/nix/netrc
    experimental-features = nix-command flakes
  '';
  nix.envVars = {
    NIX_CURL_FLAGS = "--netrc-file /etc/nix/netrc";
  };
}
