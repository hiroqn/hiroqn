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
    "com.apple.AppleMultitouchTrackpad" = {
      Clicking = true;
      FirstClickThreshold = 0;
      SecondClickThreshold = 0;
    };
    "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
      Clicking = true;
    };
    "com.apple.dock" = {
      show-recents = 0;
    };
  };
  home.stateVersion = "24.05";
}
