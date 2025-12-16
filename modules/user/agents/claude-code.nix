{ config, pkgs, ... }:

{
  programs.claude-code = {
    enable = true;
    settings = {
      theme = "dark";
      permissions = {
        # Default to asking for permission for most tools
        defaultMode = "ask";
        # Allow some safe tools by default
        allow = [
          "Bash(git diff:*)"
          "Bash(git status:*)"
          "Edit"
          "Grep"
          "Read"
        ];
      };
    };
  };
}
