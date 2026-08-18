{
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

  skillFiles = builtins.filter
    (f: lib.hasSuffix ".md" f || lib.hasSuffix ".toml" f || lib.hasSuffix ".json" f)
    (builtins.attrNames (walk skillsDir ""));

in
{
  home.file = builtins.listToAttrs (map
    (relPath: lib.nameValuePair
      ".claude/skills/${relPath}"
      { source = ./skills/${relPath}; })
    skillFiles);
}
