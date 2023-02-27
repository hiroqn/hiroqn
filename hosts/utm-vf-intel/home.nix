{ config, pkgs, ... }:
let
  shellAliases = {
    pbcopy = "xclip -selection clipboard";
    pbpaste = "xclip -selection clipboard -o";
  };
in
{
  programs.zsh = {
    inherit shellAliases;
  };
}
