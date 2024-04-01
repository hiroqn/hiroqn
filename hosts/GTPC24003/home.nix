{ config, pkgs, ... }:
{
  programs.git = {
    iniContent.credential.helper = "osxkeychain";
  };
  programs.zsh.dirHashes = {
    gh = "$HOME/GitHub";
  };
  programs.ssh = {
    enable = true;
    matchBlocks =
      let
        opAgentOption = {
          IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
        };
      in
      {
        raspberrypi = {
          host = "raspberrypi.local";
          user = "pi";
          extraOptions = opAgentOption;
        };
        utm-vf-intel = {
          host = "192.168.64.2";
          user = "hiroqn";
          extraOptions = opAgentOption;
        };
      };
  };
  targets.darwin.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false;
      NSAutomaticCapitalizationEnabled = false;
    };
    "com.apple.Accessibility" = {
      KeyRepeatEnabled = 0;
    };
    "com.apple.finder" = {
      AppleShowAllFiles = true;
      ShowPathbar = true;
    };
    "com.apple.dock" = {
      orientation = "left";
      show-recents = 0;
      persistent-apps = [ ];
    };
  };
  home.stateVersion = "24.05";
}
