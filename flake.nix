{
  description = "hiroqn env";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    BlackHole.url = "github:hiroqn/nix-BlackHole";
    BlackHole.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      home-manager,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-darwin"
        "aarch64-linux"
      ];

      imports = [
      ];

      flake = {
        darwinModules.default =
          { pkgs, ... }:
          {
            home-manager = {
              users.hiroqn.imports = [
                ./home.nix
              ];
              useGlobalPkgs = true;
              useUserPackages = true;
            };
            system.stateVersion = 4;
            nix.settings.trusted-users = [ "hiroqn" ];
          };

        darwinModules.GTPC24003 = import ./hosts/GTPC24003/default.nix;

        nixosConfigurations = {
          # UTM with Virtualization framework
          utm-aarch64-gnome = inputs.nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              (self.lib.commonNix inputs.nixpkgs)
              ./hosts/utm-aarch64-gnome/default.nix
              home-manager.nixosModules.home-manager
            ];
          };
        };

        lib = {
          commonNix =
            nixpkgs:
            { pkgs, ... }:
            {
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
