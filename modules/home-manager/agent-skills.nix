{ ... }: {
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
      subdir = "meta";
    };
    sources.k16shikano-japanese-tech-writing = {
      input = "k16shikano-japanese-tech-writing";
      subdir = ".";
    };
    sources.mattpocock-skills = {
      input = "mattpocock-skills";
      subdir = "skills";
    };
    skills.enable = [
      # hiroqn
      "update-my-env"
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
      "writing-plans"
    ];
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
    targets.agents.enable = true;
  };
}
