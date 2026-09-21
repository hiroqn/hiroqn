{
  description = "hiroqn env";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
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
    mizchi-skills = {
      url = "github:mizchi/skills";
      flake = false;
    };
    k16shikano-japanese-tech-writing = {
      url = "git+https://gist.github.com/fd287c3133457c4fd8f5601d34aa817d.git";
      flake = false;
    };
    mattpocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
    };
  };

  outputs =
    inputs@{
      flake-parts,
      home-manager,
      treefmt-nix,
      ...
    }:
    let
      lib = {
        commonNix = nixpkgs: { pkgs, ... }: {
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
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
        "aarch64-linux"
      ];

      imports = [
        treefmt-nix.flakeModule
      ];

      flake = {
        inherit lib;

        darwinModules.default = { pkgs, ... }: {
          imports = [ ./modules/nix-darwin/default.nix ];
          home-manager = {
            extraSpecialArgs = {
              inputs = {
                inherit (inputs)
                  self
                  anthropic-skills
                  agent-toolkit-for-aws
                  superpowers
                  mizchi-skills
                  k16shikano-japanese-tech-writing
                  mattpocock-skills
                  ;
                hiroqn = inputs.self;
              };
            };
            sharedModules = [
              inputs.agent-skills.homeManagerModules.default
              ./modules/home-manager/default.nix
              ./modules/home-manager/agent-skills.nix
              ./modules/home-manager/lore-server.nix
            ];
            users.hiroqn = { };
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

        packages.aarch64-linux.colima-image = colima-aarch64.config.system.build.images.qemu-efi;
      };

      perSystem =
        { pkgs, ... }:
        let
          lore = pkgs.callPackage ./packages/lore { };
          epea-co2 = pkgs.callPackage ./packages/epea-co2 { };
        in
        {
          packages.lore = lore;
          packages.epea-co2 = epea-co2;

          devShells.default = pkgs.mkShell {
            buildInputs = [
              pkgs.otel-cli
              lore
            ];
            shellHook = ''
              # ...
            '';
          };
          treefmt = {
            programs = {
              nixfmt.enable = true;
            };
          };
        };

    };
}
