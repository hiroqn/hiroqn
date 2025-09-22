{
  description = "hiroqn env";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    BlackHole.url = "github:hiroqn/nix-BlackHole";
    BlackHole.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-darwin"
        "aarch64-darwin"
        "aarch64-linux"
      ];

      imports = [
      ];

      flake = {
        darwinConfigurations = {
          "GTPC24003" = inputs.darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            modules = [
              ./darwin.nix
              (inputs.self.lib.commonNix inputs.nixpkgs)
              (
                { pkgs, ... }:
                {
                  system.stateVersion = 4;
                  nixpkgs.source = inputs.nixpkgs;
                }
              )
              ./hosts/GTPC24003/default.nix
              inputs.home-manager.darwinModules.home-manager
            ];
          };
        };

        nixosConfigurations = {
          # UTM with Virtualization framework
          utm-aarch64-gnome = inputs.nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              (inputs.self.lib.commonNix inputs.nixpkgs)
              ./hosts/utm-aarch64-gnome/default.nix
              inputs.home-manager.nixosModules.home-manager
            ];
          };
        };

        lib = {
          commonNix =
            nixpkgs:
            { pkgs, ... }:
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
              ];
              nix.extraOptions = ''
                experimental-features = nix-command flakes
              '';
              nix.registry = {
                nixpkgs = {
                  from = {
                    type = "indirect";
                    id = "nixpkgs";
                  };
                  to = {
                    type = "path";
                    path = "${nixpkgs}";
                  };
                };
              };
              nixpkgs.config.allowUnfree = true;
            };
        };
      };

      perSystem =
        { pkgs, ... }:
        {
          formatter = pkgs.nixfmt-tree;

          devShells.default = pkgs.mkShell {
            buildInputs = [
              pkgs.otel-cli
            ];
            shellHook = ''
              # ...
            '';
          };
        };
    };
}
