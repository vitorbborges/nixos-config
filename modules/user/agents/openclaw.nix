# OpenClaw — personal AI assistant, Nix-declarative install via nix-openclaw.
#
# Integration pattern (CLAUDE.md design principle #5):
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
#     OPENCODE_API_KEY=sk-...         (opencode Zen/Go — opencode.ai/auth or ~/.local/share/opencode/auth.json)
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
        # Real token comes from OPENCLAW_GATEWAY_TOKEN (secrets env file). Using a
        # SecretRef (not a literal) so every CLI (dashboard/status/tui) and the
        # gateway resolve the SAME real value. A literal placeholder here caused
        # "gateway token mismatch" because clients sent the placeholder text.
        auth = {
          mode = "token";
          token = {
            source = "env";
            provider = "default";
            id = "OPENCLAW_GATEWAY_TOKEN";
          };
        };
      };

      models = {
        mode = "merge";
        providers = {
          "opencode" = {
            baseUrl = "https://opencode.ai/zen/go/v1";
            # opencode-issued key (opencode-go) — routes billing to the opencode
            # Go subscription via the zen/go endpoint. Zen key available as
            # OPENCODE_ZEN_API_KEY (alias). The old OPENAI_API_KEY value was
            # actually the Go key (mislabeled), not OpenAI.
            apiKey = "OPENCODE_API_KEY";
            api = "openai-completions";
            models = [
              {
                id = "deepseek-v4-pro";
                name = "DeepSeek V4 Pro";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "deepseek-v4-flash";
                name = "DeepSeek V4 Flash";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "gpt-5.6-luna";
                name = "GPT-5.6 Luna";
                reasoning = false;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "grok-4.5";
                name = "Grok 4.5";
                reasoning = false;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "glm-5.3";
                name = "GLM-5.3";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "glm-5.2";
                name = "GLM-5.2";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "glm-5.1";
                name = "GLM-5.1";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "glm-5";
                name = "GLM-5";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "kimi-k3";
                name = "Kimi K3";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "kimi-k2.7-code";
                name = "Kimi K2.7 Code";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "kimi-k2.6";
                name = "Kimi K2.6";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "kimi-k2.5";
                name = "Kimi K2.5";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "qwen3.8-max";
                name = "Qwen3.8 Max";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "qwen3.7-max";
                name = "Qwen3.7 Max";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "qwen3.7-plus";
                name = "Qwen3.7 Plus";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "qwen3.6-plus";
                name = "Qwen3.6 Plus";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "qwen3.5-plus";
                name = "Qwen3.5 Plus";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "minimax-m3";
                name = "MiniMax-M3";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "minimax-m2.7";
                name = "MiniMax-M2.7";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "minimax-m2.5";
                name = "MiniMax-M2.5";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "mimo-v2.5-pro";
                name = "MiMo V2.5 Pro";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "mimo-v2.5";
                name = "MiMo V2.5";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "mimo-v2-pro";
                name = "MiMo V2 Pro";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "mimo-v2-omni";
                name = "MiMo V2 Omni";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "hy3";
                name = "Hy3";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "hy3-preview";
                name = "Hy3 Preview";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
              {
                id = "muse-spark-1.2-contributor";
                name = "Muse Spark 1.2";
                reasoning = true;
                input = [ "text" ];
                cost = { input = 0; output = 0; cacheRead = 0; cacheWrite = 0; };
                contextWindow = 200000;
                maxTokens = 8192;
              }
            ];
          };
        };
      };

      agents = {
        defaults.model.primary = "opencode/deepseek-v4-pro";
      };

      # Telegram channel: token comes from TELEGRAM_BOT_TOKEN in the secrets
      # env file (created in BotFather). First DM is approved via pairing.
      channels = {
        telegram = {
          enabled = true;
          dmPolicy = "pairing";
        };
      };

      # herdr lifecycle hook: reports working/idle to herdr panes as
      # custom:openclaw agents. Code lives at ~/.openclaw/hooks/herdr-status.
      hooks = {
        internal = {
          enabled = true;
          entries = {
            "herdr-status" = { enabled = true; };
          };
        };
      };
    };

    # systemd user service (Linux) — enabled by default.
    # Gateway listens on localhost:18789.
    systemd.enable = true;
  };

  # Inject the secrets EnvironmentFile + Install section (auto-start on boot).
  systemd.user.services.openclaw-gateway = {
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      EnvironmentFile = [
        "%h/.secrets/openclaw-gateway-token.env"
      ];
    };
  };
}
