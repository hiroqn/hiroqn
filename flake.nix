{
  description = "hiroqn env";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.utils.follows = "flake-utils";
    codex.url = "github:herp-inc/codex";

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
            })
          ./darwin-configuration.nix
          BlackHole.darwinModules.default
          home-manager.darwinModule
        ];
      };

      packages."armv6l-linux" = (import nixpkgs {
        system = "armv6l-linux";
        overlays = [
          (final: prev: {
            isdirectory = prev.lib.lowPrio (prev.callPackage ./isdirectory.nix {
              stdenv = final.pcre.stdenv;
            });
          })
        ];
      });

      nixosConfigurations = {
        pi0 = nixpkgs.lib.nixosSystem {
          system = "armv6l-linux";
          #          specialArgs = attrs;
          modules = [
            ./hosts/rpi0/default.nix
          ];
        };
      };
    } // (flake-utils.lib.eachDefaultSystem (system:
    let pkgs = nixpkgs.legacyPackages.${system}; in
    rec {
      inherit pkgs;
      devShell = pkgs.mkShell {
        buildInputs = [
          pkgs.otel-cli
        ];
        shellHook = ''
          # ...
        '';
      };
    }
    ));
}
