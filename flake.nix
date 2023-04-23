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
              # home-manager
              home-manager = {
                users.hiroqn.imports = [
                  codex.hmModule."x86_64-darwin"
                  ./home.nix
                  ./hosts/GTPC20003/home.nix
                ];
                users.hiroqn.codex.enable = true;
                useGlobalPkgs = true;
                useUserPackages = true;
              };
              BlackHole.enable = true;
            })
          ./hosts/GTPC20003/default.nix
          BlackHole.darwinModules.default
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
              })
            ./hosts/utm-vf-intel/default.nix
            home-manager.nixosModule
          ];
        };
      };
    } // (flake-utils.lib.eachDefaultSystem (system:
    let pkgs = nixpkgs.legacyPackages.${system}; in
    rec {
      inherit pkgs;
      devShells.default = pkgs.mkShell {
        buildInputs = [
          pkgs.otel-cli
          pkgs.nixpkgs-fmt
        ];
        shellHook = ''
          # ...
        '';
      };
    }
    ));
}
