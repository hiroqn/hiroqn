{
  description = "hiroqn env";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    darwin.url = "github:hiroqn/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-fmt.url = "github:nix-community/nixpkgs-fmt";
    nixpkgs-fmt.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-fmt.inputs.flake-utils.follows = "flake-utils";
    #    nixpkgs-fmt.inputs.fenix.inputs.nixpkgs.follows = "nixpkgs";

    direnv.url = "github:ruicc/direnv/support-aliases";
    direnv.flake = false;
    BlackHole.url = "github:hiroqn/nix-BlackHole";
    BlackHole.flake = false;
  };

  outputs = { self, flake-utils, darwin, nixpkgs, home-manager, nixpkgs-fmt, direnv, BlackHole }:
    let
      configuration = { pkgs, ... }: {
        nix.package = pkgs.nix_2_5;
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
    } // (flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      rec {
        apps.fmt = flake-utils.lib.mkApp { drv = pkgs.nixpkgs-fmt; };
        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.nixpkgs-fmt
            pkgs.hello
          ];
          shellHook = ''
            # ...
          '';
        };
      }
    ));
}