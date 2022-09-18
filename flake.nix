{
  description = "hiroqn env";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.utils.follows = "flake-utils";
    codex.url = "github:herp-inc/codex/add-hm-kubernetes";

    direnv.url = "github:ruicc/direnv/support-aliases";
    direnv.flake = false;
    BlackHole.url = "github:hiroqn/nix-BlackHole";
    BlackHole.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , flake-utils
    , darwin
    , nixpkgs
    , home-manager
    , codex
    , direnv
    , BlackHole
    , ...
    }:
    let
      armv6l_pkgs = (import nixpkgs { system = "armv6l-linux"; });
    in
    {
      nixpkgs = nixpkgs;
      darwinConfigurations."GTPC20003" = darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        modules = [
          ({ pkgs, ... }:
            {
              nix.nixPath = [
                {
                  inherit nixpkgs;
                }
                "/nix/var/nix/profiles/per-user/root/channels"
                "$HOME/.nix-defexpr/channels"
              ];
              home-manager.users.hiroqn.imports = [ codex.hmModule."x86_64-darwin" ];
              home-manager.users.hiroqn.codex.enable = true;
              BlackHole.enable = true;
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
                })
              ];
            })
          ./darwin-configuration.nix
          BlackHole.darwinModules.default
          home-manager.darwinModule
        ];
      };
    } // (flake-utils.lib.eachDefaultSystem (system:
    let pkgs = nixpkgs.legacyPackages.${system}; in
    rec {
      inherit pkgs;
      devShell = pkgs.mkShell {
        buildInputs = [
          (pkgs.callPackage ./otel-cli.nix { })
        ];
        shellHook = ''
          # ...
        '';
      };
    }
    ));
}
