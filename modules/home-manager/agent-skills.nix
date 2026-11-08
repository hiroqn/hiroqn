{
  darwinInputs ? null,
  lib,
  ...
}:
{
  programs.agent-skills = {
    enable = true;
    sources.hiroqn-skills = {
      input = "self";
      subdir = "skills";
    };
    sources.anthropic = {
      input = "anthropic-skills";
      subdir = "skills";
    };
    sources.aws = {
      input = "agent-toolkit-for-aws";
      subdir = "skills/core-skills";
    };
    sources.superpowers = {
      input = "superpowers";
      subdir = "skills";
    };
    sources.mizchi = {
      input = "mizchi-skills";
      subdir = ".";
    };
    sources.k16shikano-japanese-tech-writing = {
      input = "k16shikano-japanese-tech-writing";
      subdir = ".";
    };
    sources.mattpocock-skills = {
      input = "mattpocock-skills";
      subdir = "skills";
    };
    sources.kotek7-dotfiles = {
      input = "kotek7-dotfiles";
      subdir = "dot_agents/skills";
      idPrefix = "kotek7";
    };
    sources.openclaw = {
      input = "openclaw";
      subdir = ".agents/skills";
    };
    skills.enable = [
      # hiroqn。about-env は explicit で、darwin-rebuild の rev を SKILL.md に埋める
      "terraform-troubleshooting"
      # openclaw
      "test-audit"
      # mizchi
      "retrospective-codify"
      # anthropic
      "doc-coauthoring"
      # aws
      "amazon-bedrock"
      "aws-billing-and-cost-management"
      "aws-iam"
      # superpowers
      "brainstorming"
      "systematic-debugging"
      "test-driven-development"
    ];
    # skills.explicit.about-env = {
    #   from = "hiroqn-skills";
    #   transform =
    #     { original, ... }:
    #     if darwinInputs == null then
    #       throw "about-env: darwinInputs が無い。/etc/nix-darwin の extraSpecialArgs.darwinInputs を渡す"
    #     else
    #       (import ./about-env-skill.nix { inherit lib; }) {
    #         nixDarwinRev = darwinInputs.nix-darwin.rev or null;
    #         homeManagerRev = darwinInputs.home-manager.rev or null;
    #         nixpkgsRev = darwinInputs.nixpkgs.rev or null;
    #       } original;
    # };
    skills.explicit."japanese-tech-writing" = {
      from = "k16shikano-japanese-tech-writing";
      path = ".";
    };
    skills.explicit."grill-me" = {
      from = "mattpocock-skills";
      path = "productivity/grill-me";
    };
    skills.explicit."grilling" = {
      from = "mattpocock-skills";
      path = "productivity/grilling";
    };
    skills.explicit."sanitize-artifacts" = {
      from = "kotek7-dotfiles";
      path = "sanitize-artifacts";
    };
    targets.agents.enable = true;
  };
}
