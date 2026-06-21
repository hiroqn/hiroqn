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
    skills.enable = [
      # hiroqn
      "nixify-env"
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
    targets.agents.enable = true;
  };
}
