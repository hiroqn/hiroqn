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
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";
    vscode-server.inputs.flake-utils.follows = "flake-utils";
  };

  outputs =
    { self
    , flake-utils
    , darwin
    , nixpkgs
    , home-manager
    , BlackHole
    , vscode-server
    , ...
    }:
    let
      commonNix = { pkgs, ... }:
        {
          nix.nixPath = [
            {
              inherit nixpkgs;
            }
            "$HOME/.nix-defexpr/channels"
          ];
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
              home-manager = {
                users.hiroqn.imports = [
                  ./home.nix
                  ./hosts/GTPC20003/home.nix
                ];
                useGlobalPkgs = true;
                useUserPackages = true;
              };
              system.stateVersion = 4;
              BlackHole.enable = true;
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
              home-manager = {
                users.hiroqn.imports = [
                  ./home.nix
                ];
                useGlobalPkgs = true;
                useUserPackages = true;
              };
              system.stateVersion = 4;
            })
          ./hosts/GTPC24003/default.nix
          home-manager.darwinModule
        ];
      };
      nixosConfigurations = {
        # UTM with Virtualization framework
        utm-vf-intel = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ({ pkgs, ... }:
              {
                nix.nixPath = [
                  "nixpkgs=${nixpkgs}"
                  "/nix/var/nix/profiles/per-user/root/channels"
                  "$HOME/.nix-defexpr/channels"
                ];

                # home-manager
                home-manager = {
                  users.hiroqn.imports = [
                    ./home.nix
                    ./hosts/utm-vf-intel/home.nix
                  ];
                  useGlobalPkgs = true;
                  useUserPackages = true;
                };
                services.vscode-server.enable = true;
              })
            ./hosts/utm-vf-intel/default.nix
            home-manager.nixosModule
            vscode-server.nixosModules.default
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
