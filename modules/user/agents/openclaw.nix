# OpenClaw — personal AI assistant, Nix-declarative install via nix-openclaw.
#
# Integration pattern (CLAUDE.md design principle #4):
#   External flake inputs arrive via extraSpecialArgs → imported here.
#
# Workspace bootstrap:
#   OpenClaw generates its workspace files (AGENTS.md, SOUL.md, etc.) on first
#   gateway start. We intentionally do NOT set workspace.bootstrapFiles, letting
#   openclaw's own initialization handle it. To later pin them with Nix, set
#   workspace.bootstrapFiles = { ... } and reference source files.
#
# Secrets:
#   Create ~/.secrets/openclaw-gateway-token.env with:
#     OPENCLAW_GATEWAY_TOKEN=<openssl rand -hex 32>
#     ANTHROPIC_API_KEY=sk-ant-...    (or OPENAI_API_KEY, etc.)
#   The systemd service reads this file via EnvironmentFile.

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    inputs.nix-openclaw.homeManagerModules.openclaw
  ];

  programs.openclaw = {
    enable = true;

    # Schema-typed OpenClaw config (generated as ~/.openclaw/openclaw.json).
    # In Nix mode this file is read-only — changes must be made here and
    # applied via home-manager switch.
    config = {
      gateway = {
        mode = "local";
        # The gateway auth token is injected at runtime via
        # OPENCLAW_GATEWAY_TOKEN env var (from the EnvironmentFile).
        # The string below is a fallback — the env var takes precedence.
        auth.token = "placeholder-set-via-env";
      };
    };

    # systemd user service (Linux) — enabled by default.
    # Gateway listens on localhost:18789.
    systemd.enable = true;
  };

  # Inject the secrets EnvironmentFile into the systemd user service.
  systemd.user.services.openclaw-gateway = {
    Service = {
      EnvironmentFile = [
        "%h/.secrets/openclaw-gateway-token.env"
      ];
    };
  };
}
