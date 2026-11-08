{ pkgs, ... }:
{
  # hiroqn-private 専用。このユーザーの imports からのみ読む。
  home.packages = [
    (pkgs.callPackage ../../packages/supermemory { })
  ];

  programs.agent-skills = {
    sources.supermemory = {
      input = "supermemory-skills";
      subdir = ".";
    };
    skills.enable = [
      "supermemory"
      "supermemory-cli"
    ];
  };
}
