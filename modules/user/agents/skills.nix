{
  inputs,
  lib,
  ...
}:

let
  skillsDir = ./skills;

  # Walk skillsDir, threading the relative path as a pure name string (no
  # store-path context) and the absolute path as a path value.
  walk = dir: rel:
    lib.foldl'
      (acc: name:
        if (builtins.readDir dir).${name} == "directory"
        then acc // (walk (dir + "/${name}") "${rel}${name}/")
        else acc // { "${rel}${name}" = dir + "/${name}"; })
      { }
      (builtins.attrNames (builtins.readDir dir));

  repoSkillFiles = builtins.filter
    (f: lib.hasSuffix ".md" f || lib.hasSuffix ".toml" f || lib.hasSuffix ".json" f || lib.hasSuffix ".sh" f)
    (builtins.attrNames (walk skillsDir ""));

  repoSkills = builtins.listToAttrs (map
    (relPath: lib.nameValuePair
      ".claude/skills/${relPath}"
      { source = ./skills/${relPath}; })
    repoSkillFiles);

  # Third-party skills vendored from flake inputs (declared in flake.nix).
  # Explicit paths only: cherry-pick SKILL.md plus the files it references
  # rather than importing whole upstream trees. Adding a skill = add its
  # paths here, git add, rebuild.
  vendorSkills = {
    ".claude/skills/i-have-adhd/SKILL.md".source =
      inputs.i-have-adhd + "/skills/i-have-adhd/SKILL.md";

    ".claude/skills/humanizer/SKILL.md".source =
      inputs.humanizer + "/SKILL.md";

    ".claude/skills/systematic-debugging/SKILL.md".source =
      inputs.superpowers + "/skills/systematic-debugging/SKILL.md";
    ".claude/skills/systematic-debugging/root-cause-tracing.md".source =
      inputs.superpowers + "/skills/systematic-debugging/root-cause-tracing.md";
    ".claude/skills/systematic-debugging/defense-in-depth.md".source =
      inputs.superpowers + "/skills/systematic-debugging/defense-in-depth.md";
    ".claude/skills/systematic-debugging/condition-based-waiting.md".source =
      inputs.superpowers + "/skills/systematic-debugging/condition-based-waiting.md";

    ".claude/skills/requesting-code-review/SKILL.md".source =
      inputs.superpowers + "/skills/requesting-code-review/SKILL.md";
    ".claude/skills/requesting-code-review/code-reviewer.md".source =
      inputs.superpowers + "/skills/requesting-code-review/code-reviewer.md";

    ".claude/skills/verification-before-completion/SKILL.md".source =
      inputs.superpowers + "/skills/verification-before-completion/SKILL.md";

    ".claude/skills/ponytail/SKILL.md".source =
      inputs.ponytail + "/skills/ponytail/SKILL.md";
    ".claude/skills/ponytail-review/SKILL.md".source =
      inputs.ponytail + "/skills/ponytail-review/SKILL.md";
    ".claude/skills/ponytail-audit/SKILL.md".source =
      inputs.ponytail + "/skills/ponytail-audit/SKILL.md";
    ".claude/skills/ponytail-debt/SKILL.md".source =
      inputs.ponytail + "/skills/ponytail-debt/SKILL.md";
  };
in
{
  home.file = repoSkills // vendorSkills;
}
