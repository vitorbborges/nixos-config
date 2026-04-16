{
  config,
  pkgs,
  lib,
  ...
}: {
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

  # Create the two config directories using home-manager's activation
  home.activation.createClaudeProfiles = config.lib.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "$HOME/.claude-personal" "$HOME/.claude-friend"
  '';

  # Shell aliases (these are fine in home-manager)
  programs.bash.shellAliases = {
    claude-personal = "CLAUDE_CONFIG_DIR=~/.claude-personal claude";
    claude-friend = "CLAUDE_CONFIG_DIR=~/.claude-friend claude";
  };

  programs.zsh.shellAliases = {
    claude-personal = "CLAUDE_CONFIG_DIR=~/.claude-personal claude";
    claude-friend = "CLAUDE_CONFIG_DIR=~/.claude-friend claude";
  };
}
