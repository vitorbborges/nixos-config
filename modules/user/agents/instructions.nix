{ inputs, ... }:

let
  bootstrap = builtins.readFile ./bootstrap.md;

  # Ponytail's instruction-only mode: its repo-root AGENTS.md is the always-on
  # ruleset (the opencode plugin's equivalent of the npm plugin hook injection).
  # Strip the line that scopes it to the ponytail repo itself.
  ponytailRules = builtins.replaceStrings
    [ "(Yes, this file also applies to agents working on the ponytail repo itself. Especially to them.)" ]
    [ "(These rules apply to every coding session.)" ]
    (builtins.readFile (inputs.ponytail + "/AGENTS.md"));
in
{
  # Global opencode instructions — loaded into every session regardless of
  # project. Two layers: the skill-activation bootstrap, and ponytail's
  # lazy-dev ruleset (always-on, no invocation needed).
  home.file.".config/opencode/AGENTS.md".text = ''
    ${bootstrap}

    ---

    ${ponytailRules}
  '';
}
