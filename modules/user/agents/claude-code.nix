{
  config,
  pkgs,
  ...
}: {
  # Your existing claude-code configuration (unchanged)
  programs.claude-code = {
    enable = true;
    settings = {
      theme = "dark";
      permissions = {
        defaultMode = "default";
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

  # ----- NEW: Two‑profile setup -----

  # 1. Create the isolated config directories automatically for your user
  #    (runs once at first login; safe to keep)
  system.userActivationScripts.createClaudeProfiles = {
    text = ''
      mkdir -p "$HOME/.claude-personal" "$HOME/.claude-friend"
    '';
    deps = []; # no dependencies needed
  };

  # 2. Add shell aliases for bash and zsh (the two most common shells on NixOS)
  programs.bash.shellAliases = {
    claude-personal = "CLAUDE_CONFIG_DIR=~/.claude-personal claude";
    claude-friend = "CLAUDE_CONFIG_DIR=~/.claude-friend claude";
  };

  programs.zsh.shellAliases = {
    claude-personal = "CLAUDE_CONFIG_DIR=~/.claude-personal claude";
    claude-friend = "CLAUDE_CONFIG_DIR=~/.claude-friend claude";
  };
}
