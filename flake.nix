{
  description = "hiroqn env";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/7053541084bf5ce2921ef307e5585d39d7ba8b3f";
    darwin.url = "github:hiroqn/nix-darwin/8d08584a321855f3178054e8f6bb3c324b7fcdfd";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, darwin, nixpkgs }: {
    darwinConfigurations."veda-20210910" = darwin.lib.darwinSystem {
      system = "x86_64-darwin";
      modules = [ ./darwin-configuration.nix ];
    };
  };
}

