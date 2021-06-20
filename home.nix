{ config, pkgs, ...  }:
let
  shellAliases = {
    ll = "ls -lh";
    lal = "ls -a -lA";
    greo = "grep --colour=auto";
  };
in
{
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
      extended = true;
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
      source ${pkgs.callPackage ./nix/fzf-tab.nix {}}/fzf-tab.plugin.zsh
      source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh
    '';
  };
  programs.direnv = {
    enable = true;
    enableNixDirenvIntegration = true;
  };
  programs.git = {
    enable = true;
    userEmail = "hiroqn1008@gmail.com";
    userName = "hiroqn";
    signing.key = "C3BF7281D87D87084E332DDC4F22B8FA3412D901";
    lfs.enable = true;
    delta.enable = true;
    iniContent.credential.helper = "osxkeychain";
    ignores = [ ".idea" ".DS_Store"  ".env" "*.iml" ".direnv"];
  };
  programs.alacritty = {
    enable = true;
    settings = {
      window.decorations = "transparent";
      background_opacity = 0.8;
      shell = {
        program = "${pkgs.zsh}/bin/zsh";
        args = ["--login"];
      };
      font.size = 12.0;
    };
  };
}
