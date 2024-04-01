{ pkgs, config, ... }:
{
  services.nix-daemon.enable = true;
  nix.configureBuildUsers = true;
  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    netrc-file = /etc/nix/netrc
    experimental-features = nix-command flakes
  '';
  nixpkgs.config.allowUnfree = true;
}
