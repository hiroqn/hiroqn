{ config, ... }:
let
  source = import ./nix/sources.nix;
  nixpkgs = import source.nixpkgs {};
  desktop = nixpkgs.callPackage ./nix/github-desktop.nix {};
  pure = nixpkgs.callPackage ./nix/zsh-pure.nix {};
  fzf-tab = nixpkgs.callPackage ./nix/fzf-tab.nix {};
  fast-syntax-highlighting = nixpkgs.callPackage ./nix/fast-syntax-highlighting.nix {};
  shellAliases = {
    ls = "ls -GFS";
    ll = "ls -lh";
    lal = "ls -a -lA";
    greo = "grep --colour=auto";
  };
  in
{
  # for some build
  nixpkgs.config.allowUnfree = true;

  users.users.hiroqn.name = "hiroqn";
  users.users.hiroqn.home = "/Users/hiroqn";

  # home-manager
  imports = [ "${source.home-manager}/nix-darwin" ];
  home-manager = {
    useUserPackages = true;
    users.hiroqn = { ... }: {
      nixpkgs.config.allowUnfree = true;
      home.packages = [ ];
      xdg = {
        enable = true;
        configFile."nixpkgs/config.nix".source = ./config.nix;
      };

      programs.bash = {
        enable = true;
        inherit shellAliases;
      };
      programs.zsh = {
        enable = true;
        history = {
          size = 10000;
          save = 10000;
          ignoreDups = true;
          ignoreSpace = true;
          share = true;
        };
        autocd = true;
        inherit shellAliases;
        initExtra = ''
          setopt print_eight_bit        # 日本語ファイル名を表示可能にする
          setopt no_flow_control        # フローコントロールを無効にする
          setopt interactive_comments   # '#' 以降をコメントとして扱う
          setopt auto_pushd             # cd したら自動的にpushdする
          setopt pushd_ignore_dups      # 重複したディレクトリを追加しない
          setopt magic_equal_subst      # = の後はパス名として補完する
          setopt hist_ignore_all_dups   # 同じコマンドをヒストリに残さない
          setopt hist_save_nodups       # ヒストリファイルに保存するとき、すでに重複したコマンドがあったら古い方を削除する
          setopt hist_reduce_blanks     # ヒストリに保存するときに余分なスペースを削除する
          setopt inc_append_history
          setopt inc_append_history     # ヒストリをインクリメンタルに追加する
          setopt auto_menu              # 補完候補が複数あるときに自動的に一覧表示する
          setopt globdots               # 明確なドットの指定なしで.から始まるファイルをマッチ
          setopt extended_glob          # 高機能なワイルドカード展開を使用する
          setopt combining_chars        # Unicode の正規化に関する問題を吸収
          hash -d dev=$HOME/.dev
          autoload -Uz add-zsh-hook
          chpwd_static_named_directory() {
            local gitroot=$(git rev-parse --show-toplevel 2>/dev/null)
            if [ ! "$gitroot" = "" ]; then
              hash -d "git=$gitroot"
              return
            else
              hash -d git=
            fi
          }
          chpwd_static_named_directory
          add-zsh-hook chpwd chpwd_static_named_directory
          source ${fzf-tab}/fzf-tab.plugin.zsh
          source ${fast-syntax-highlighting}/fast-syntax-highlighting.plugin.zsh
        '';
      };
      programs.git = {
        enable = true;
        userEmail = "hiroqn1008@gmail.com";
        userName = "hiroqn";
        signing.key = "C3BF7281D87D87084E332DDC4F22B8FA3412D901";
        lfs.enable = true;
        delta.enable = true;
        iniContent.credential.helper = "osxkeychain";
        ignores = [ ".idea" ".DS_Store"  ".envrc" "*.iml" ];
      };
      programs.alacritty = {
        enable = true;
        settings = {
          window.decorations = "transparent";
          background_opacity = 0.8;
          shell = {
            program = "${nixpkgs.zsh}/bin/zsh";
            args = ["--login"];
          };
          font.size = 12.0;
        };
      };
    };
  };
  # system config
  fonts.enableFontDir = true;
  fonts.fonts = [ nixpkgs.monoid ];
  environment.systemPackages =
    [
      (import source.niv {}).niv
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
      pure
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
  system.stateVersion = 3;

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
  nix.package = nixpkgs.nix;
}
