{
  description = "hiroqn env";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    BlackHole.url = "github:hiroqn/nix-BlackHole";
    BlackHole.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    nixos-lima.url = "github:nixos-lima/nixos-lima";
    nixos-lima.inputs.nixpkgs.follows = "nixpkgs";
    agent-skills.url = "github:Kyure-A/agent-skills-nix";
    anthropic-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };
    agent-toolkit-for-aws = {
      url = "github:aws/agent-toolkit-for-aws";
      flake = false;
    };
    superpowers = {
      url = "github:obra/superpowers/v5.1.0";
      flake = false;
    };
  };

  outputs = inputs@{ flake-parts, home-manager, treefmt-nix, ... }:
    let
      lib = {
        commonNix = nixpkgs:
          { pkgs, ... }: {
            nixpkgs.config.allowUnfree = true;
          };
      };

      colima-aarch64 = inputs.nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          (lib.commonNix inputs.nixpkgs)
          inputs.nixos-lima.nixosModules.lima
          ./hosts/colima-aarch64/default.nix
        ];
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems =
        [ "x86_64-linux" "aarch64-darwin" "aarch64-linux" ];

      imports = [ treefmt-nix.flakeModule ];

      flake = {
        inherit lib;

        darwinModules.default = { pkgs, ... }: {
          home-manager = {
            extraSpecialArgs = {
              inputs = {
                inherit (inputs)
                  self
                  anthropic-skills
                  agent-toolkit-for-aws
                  superpowers
                  ;
                hiroqn = inputs.self;
              };
            };
            users.hiroqn.imports = [
              inputs.agent-skills.homeManagerModules.default
              ./home.nix
              ./modules/home-manager/agent-skills.nix
            ];
            useGlobalPkgs = true;
          };
          nix.settings.trusted-users = [ "hiroqn" ];
        };

        darwinModules.GTPC24003 = import ./hosts/GTPC24003/default.nix;

        nixosConfigurations = {
          utm-aarch64-gnome = inputs.nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              (lib.commonNix inputs.nixpkgs)
              ./hosts/utm-aarch64-gnome/default.nix
              home-manager.nixosModules.home-manager
            ];
          };

          inherit colima-aarch64;
        };

        packages.aarch64-linux.colima-image =
          colima-aarch64.config.system.build.images.qemu-efi;
      };

      perSystem = { pkgs, ... }: {
        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.otel-cli ];
          shellHook = ''
            # ...
          '';
        };
        treefmt = { programs = { nixfmt.enable = true; }; };
      };

    };
}
