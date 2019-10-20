{ config, pkgs, ... }:
let
  yarn = pkgs.yarn.override {
    nodejs = pkgs.nodejs-10_x;
  };
  desktop = pkgs.callPackage ./github-desktop.nix {};
  pure = pkgs.callPackage ./zsh-pure.nix {};
  vscode = pkgs.callPackage ./vscode.nix {
    vscodeExtensions = with pkgs.vscode-extensions; [
      bbenoist.Nix
    ]
    ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "asciidoctor-vscode";
        publisher = "joaompinto";
        version = "0.15.1";
        sha256 = "1x6fl6nixbyg3rjsh0vrwbvcn045z598p86mih8k0s0brd8s6wfc";
      }
      {
        name = "reasonml";
        publisher = "freebroccolo";
        version = "1.0.38";
        sha256 = "1nay6qs9vcxd85ra4bv93gg3aqg3r2wmcnqmcsy9n8pg1ds1vngd";
      }
      {
        name = "terraform";
        publisher = "mauve";
        version = "1.3.7";
        sha256 = "07yn4x2ad5bcxzrxfji8vq9z416551v4ad41b4id389zg886am86";
      }
      {
        name = "EditorConfig";
        publisher = "EditorConfig";
        version = "0.12.5";
        sha256 = "07mgckafw01bpznm1rb6amvy1j835d8m9zkvpnqmyssbka7zmgz7";
      }
      {
        name = "graphql-for-vscode";
        publisher = "kumar-harsh";
        version = "1.12.1";
        sha256 = "0734a35326iqk4iqh92gxki60834frz8yxykqc90baqcq37sxzim";
      }
    ];
  };
  # clamav setting
  clamav = pkgs.callPackage ./clamav.nix {};
  stateDir = "/var/lib/clamav";
  runDir = "/run/clamav";
  clamavUser = "clamav";
  clamdConfigFile = pkgs.writeText "clamd.conf" ''
    DatabaseDirectory ${stateDir}
    LocalSocket ${runDir}/clamd.ctl
    PidFile ${runDir}/clamd.pid
    TemporaryDirectory /tmp
    User ${clamavUser}
    Foreground yes
    ExcludePath ^/System/
    ExcludePath ^/Volumes/
    ExcludePath ^/Network/
    ExcludePath ^/bin/
    ExcludePath ^/sbin/
    ExcludePath ^/nix/
  '';

  freshclamConfigFile = pkgs.writeText "freshclam.conf" ''
    DatabaseDirectory ${stateDir}
    Foreground yes
    Checks 12
    DatabaseMirror database.clamav.net
  '';
  in
{
  nixpkgs.config.allowUnfree = true;
  fonts.enableFontDir = true;
  fonts.fonts = [ pkgs.monoid ];
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 25;
  system.defaults.NSGlobalDomain.KeyRepeat = 3;
  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
  system.defaults.trackpad.Clicking = true;

  environment.systemPackages =
    [ pkgs.vim
      pkgs.emacs
      pkgs.git
      pkgs.fzf
      pkgs.gnupg
      pkgs.alacritty
      pkgs.nodejs-10_x
      pkgs.gnumake
      pkgs.jq
      yarn
      vscode
      desktop
      clamav
    ];
  environment.shells = [ pkgs.zsh ];
  environment.variables.PAGER = "cat";
  environment.variables.EDITOR = "${pkgs.vim}/bin/vi";
  environment.variables.LANG = "en_US.UTF-8";
  environment.variables.XDG_CONFIG_HOME = "$HOME/.config";
  environment.shellAliases.ls = "ls -GFS";
  environment.shellAliases.ll = "ls -lh";
  environment.shellAliases.lal = "ls -a -lA";
  environment.shellAliases.k = "kubectl";
  environment.shellAliases.greo = "grep --colour=auto";

  system.defaults.dock.autohide = false;
  system.defaults.dock.orientation = "left";

  # clamav setting
  environment.etc."clamav/freshclam.conf".source = freshclamConfigFile;
  environment.etc."clamav/clamd.conf".source = clamdConfigFile;

  users.users.clamav.uid = 599;
  users.users.clamav.gid = config.users.groups.clamav.gid;
  users.users.clamav.home = stateDir;
  users.users.clamav.shell = "/bin/false";
  users.users.clamav.description = "clamav service user";

  users.groups.clamav.gid = 799;
  users.groups.clamav.description = "group for clamav service";
  users.knownGroups = [ clamavUser ];
  users.knownUsers = [ clamavUser ];
  launchd.daemons.freshclam = {
    command = "${clamav}/bin/freshclam";
    serviceConfig.UserName = clamavUser;
    serviceConfig.GroupName = clamavUser; 
    serviceConfig.ProcessType = "Background";
    serviceConfig.StartCalendarInterval = [{
      Hour = 18;
      Minute = 0;
      Weekday = 3;
    }];
  };
  launchd.daemons.clamd = {
    command = "${clamav}/bin/clamd";
    serviceConfig.UserName = clamavUser;
    serviceConfig.GroupName = clamavUser; 
    serviceConfig.ProcessType = "Background";
    serviceConfig.RunAtLoad = true;
  };

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.bash.enable = true;

  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.enableSyntaxHighlighting = true;
  programs.zsh.enableFzfHistory = true;
  programs.zsh.enableFzfGit = true;
  programs.zsh.enableFzfCompletion = true;
  programs.zsh.interactiveShellInit = ''
    export PURE_GIT_PULL=0
    source ${pure}/share/zsh/site-functions/async
    source ${pure}/share/zsh/site-functions/prompt_pure_setup
    setopt print_eight_bit        # 日本語ファイル名を表示可能にする
    setopt no_flow_control        # フローコントロールを無効にする
    setopt interactive_comments   # '#' 以降をコメントとして扱う
    setopt auto_pushd             # cd したら自動的にpushdする
    setopt pushd_ignore_dups      # 重複したディレクトリを追加しない
    setopt magic_equal_subst      # = の後はパス名として補完する
    setopt hist_ignore_all_dups   # 同じコマンドをヒストリに残さない
    setopt hist_save_nodups       # ヒストリファイルに保存するとき、すでに重複したコマンドがあったら古い方を削除する
    setopt hist_ignore_space      # スペースから始まるコマンド行はヒストリに残さない
    setopt hist_reduce_blanks     # ヒストリに保存するときに余分なスペースを削除する
    setopt inc_append_history
    setopt share_history          # 同時に起動したzshのヒストリー共有
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
  '';
  # pure maybe fuck
  programs.zsh.promptInit = "";

  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableSSHSupport = true;
  programs.tmux.enable = true;
  programs.tmux.enableSensible = true;
  programs.tmux.enableMouse = true;
  programs.tmux.enableFzf = true;
  programs.tmux.enableVim = true;

  programs.tmux.tmuxConfig = ''
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
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 3;
  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  networking.hostName = "brahman";
  nix.maxJobs = 8;
  nix.buildCores = 8;
}
