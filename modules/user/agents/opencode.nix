{ pkgs, ... }:
{
  # Terminal-native open-source coding agent (opencode.ai). Provider-agnostic —
  # auth/credentials are handled by `opencode auth login` at runtime, stored
  # in ~/.local/share/opencode/auth.json. Never put API keys here.
  home.packages = [ pkgs.opencode ];
}
