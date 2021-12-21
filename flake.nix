{
  description = "hiroqn env";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/7053541084bf5ce2921ef307e5585d39d7ba8b3f";
    darwin.url = "github:hiroqn/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-fmt.url = "github:nix-community/nixpkgs-fmt";
    nixpkgs-fmt.inputs.nixpkgs.follows = "nixpkgs";
    direnv.url = "github:ruicc/direnv/support-aliases";
    direnv.flake = false;
    BlackHole.url = "github:hiroqn/nix-BlackHole";
    BlackHole.flake = false;
  };

  outputs = { self, darwin, nixpkgs, home-manager, nixpkgs-fmt, direnv, BlackHole }:
    let
      configuration = { pkgs, ... }: {
        nix.package = pkgs.nix_2_4;
        nix.nixPath = [
          {
            inherit nixpkgs;
          }
          "/nix/var/nix/profiles/per-user/root/channels"
          "$HOME/.nix-defexpr/channels"
        ];
        environment.systemPackages = [
          nixpkgs-fmt.defaultPackage."x86_64-darwin"
        ];
        nixpkgs.overlays = [
          (final: prev: {
            direnv = (prev.direnv.override rec {
              buildGoModule = args: prev.buildGoModule (args // {
                src = direnv;
                version = "2.28.0-ruicc";
                vendorSha256 = "sha256-P8NLY1iGh86ntmYsTVlnNh5akdaM8nzcxDn6Nfmgr84=";
              });
            }).overrideAttrs (oldAttrs: rec {
              doCheck = false;
            });
            blackhole = prev.callPackage BlackHole { };
          })
        ];
      };
    in
    {
      darwinConfigurations."veda-20210910" = darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        modules = [ configuration home-manager.darwinModule ./darwin-configuration.nix ];
      };
    };
}
