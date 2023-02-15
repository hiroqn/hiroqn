{ config, pkgs, ... }:
{
  programs.git = {
    iniContent.credential.helper = "osxkeychain";
  };
}
