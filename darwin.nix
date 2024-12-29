{ pkgs, config, ... }:
{
  services.nix-daemon.enable = true;
  nix.configureBuildUsers = true;
  nix.package = pkgs.nixVersions.nix_2_24;
}
