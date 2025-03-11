{ pkgs, config, ... }:
{
  nix.enable = true;
  nix.package = pkgs.nixVersions.nix_2_24;
}
