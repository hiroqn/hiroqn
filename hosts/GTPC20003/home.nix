{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.terminal-notifier
  ];
  programs.git = {
    iniContent.credential.helper = "osxkeychain";
  };
  targets.darwin.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 25;
      KeyRepeat = 3;
      NSAutomaticCapitalizationEnabled = false;
      "com.apple.trackpad.scaling" = "2.5";
      "com.apple.trackpad.scrolling" = "0.4412";
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
}
