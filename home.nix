{ config, pkgs, ... }:
let
  shellAliases = {
    ll = "ls -lh";
    lal = "ls -a -lA";
    greo = "grep --colour=auto";
  };
in
{
  xdg = {
    enable = true;
    configFile."nixpkgs/config.nix".source = ./config.nix;
  };
  home.packages = [
    pkgs.coreutils
    pkgs.nix-prefetch-git
    pkgs.openssh
    pkgs.vim
  ];

  programs.atuin = {
    enable = true;
    settings = {
      update_check = false;
    };
  };
  programs.bash = {
    enable = true;
    inherit shellAliases;
  };
  programs.fzf = {
    enable = true;
  };
  programs.starship = {
    enable = true;
  };
  programs.zellij = {
    enable = true;
  };
  programs.zsh = {
    enable = true;
    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
      share = true;
    };
    autocd = true;
    defaultKeymap = "emacs";
    inherit shellAliases;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
      setopt print_eight_bit        # 日本語ファイル名を表示可能にする
      setopt no_flow_control        # フローコントロールを無効にする
      setopt auto_pushd             # cd したら自動的にpushdする
      setopt pushd_ignore_dups      # 重複したディレクトリを追加しない
      setopt magic_equal_subst      # = の後はパス名として補完する
      setopt hist_ignore_all_dups   # 同じコマンドをヒストリに残さない
      setopt hist_save_nodups       # ヒストリファイルに保存するとき、すでに重複したコマンドがあったら古い方を削除する
      setopt hist_reduce_blanks     # ヒストリに保存するときに余分なスペースを削除する
      setopt inc_append_history     # ヒストリをインクリメンタルに追加する
      setopt auto_menu              # 補完候補が複数あるときに自動的に一覧表示する
      setopt globdots               # 明確なドットの指定なしで.から始まるファイルをマッチ
      setopt combining_chars        # Unicode の正規化に関する問題を吸収
      autoload -Uz add-zsh-hook
      chpwd_static_named_directory() {
        local gitroot=$(git rev-parse --show-toplevel 2>/dev/null)
        if [ -n "$gitroot" ]; then
          hash -d "git=$gitroot"
          return
        else
          hash -d git=
        fi
      }

      chpwd_static_named_directory
      add-zsh-hook chpwd chpwd_static_named_directory
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
    '';
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.git = {
    enable = true;
    userEmail = "909385+hiroqn@users.noreply.github.com";
    userName = "hiroqn";
    signing.key = "C3BF7281D87D87084E332DDC4F22B8FA3412D901";
    lfs.enable = true;
    delta.enable = true;
    ignores = [ ".idea" ".DS_Store" "*.iml" ".direnv" ];
  };
  programs.alacritty = {
    enable = true;
    settings = {
      window.padding.x = 5;
      window.padding.y = 5;
      window.opacity = 0.8;
      font.size = 12.0;
    };
  };
}
