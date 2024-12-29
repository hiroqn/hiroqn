{
  description = "hiroqn env";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    darwin.url = "github:hiroqn/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    BlackHole.url = "github:hiroqn/nix-BlackHole";
    BlackHole.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , flake-utils
    , darwin
    , nixpkgs
    , home-manager
    , BlackHole
    , ...
    }:
    let
      commonNix = { pkgs, ... }:
        {
          home-manager = {
            users.hiroqn.imports = [
              ./home.nix
            ];
            useGlobalPkgs = true;
            useUserPackages = true;
          };
          nix.nixPath = [
            "nixpkgs=${nixpkgs}"
            "$HOME/.nix-defexpr/channels"
          ];
          nix.extraOptions = ''
            experimental-features = nix-command flakes
          '';
          nix.registry = {
            nixpkgs = {
              from = { type = "indirect"; id = "nixpkgs"; };
              to = {
                type = "path";
                path = "${nixpkgs}";
              };
            };
          };
          nixpkgs.config.allowUnfree = true;
        };
    in
    {
      darwinConfigurations."GTPC20003" = darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        modules = [
          ./darwin.nix
          commonNix
          ({ pkgs, ... }:
            {
              system.stateVersion = 4;
              BlackHole.enable = true;
              nixpkgs.source = nixpkgs;
            })
          ./hosts/GTPC20003/default.nix
          BlackHole.darwinModules.default
          home-manager.darwinModule
        ];
      };

      darwinConfigurations."GTPC24003" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./darwin.nix
          commonNix
          ({ pkgs, ... }:
            {
              system.stateVersion = 4;
              nixpkgs.source = nixpkgs;
            })
          ./hosts/GTPC24003/default.nix
          home-manager.darwinModule
        ];
      };
      nixosConfigurations = {
        # UTM with Virtualization framework
        utm-aarch64-gnome = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            commonNix
            ./hosts/utm-aarch64-gnome/default.nix
            home-manager.nixosModule
          ];
        };
      };
    } // (flake-utils.lib.eachDefaultSystem (system:
    let pkgs = nixpkgs.legacyPackages.${system}; in
    rec {
      formatter = pkgs.nixpkgs-fmt;
      devShells.default = pkgs.mkShell {
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
