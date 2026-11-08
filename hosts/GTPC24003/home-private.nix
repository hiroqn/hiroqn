{
  pkgs,
  inputs,
  ...
}:
{
  # hiroqn-private 専用。このユーザーの imports からのみ読む。
  home.packages = [
    (pkgs.callPackage ../../packages/supermemory { })
  ];

  programs.agent-skills = {
    sources.supermemory = {
      path = pkgs.callPackage ../../packages/supermemory/skills.nix {
        src = inputs.supermemory-skills;
      };
      subdir = ".";
    };
    skills.enable = [
      "supermemory"
      "supermemory-cli"
    ];
  };
}
