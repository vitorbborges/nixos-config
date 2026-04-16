# LlamaFS — self-organizing file manager
#
# Provides:
#   llama-fs-server   FastAPI server (batch + watch API on :8000)
#   llama-fs          CLI batch mode
#
# Usage:
#   llama-fs-server                    # start the API
#   curl -X POST http://127.0.0.1:8000/batch \
#     -H "Content-Type: application/json" \
#     -d '{"path": "/home/vitor/Downloads", "incognito": false}'
#
# Required env vars (put in ~/.config/llama-fs/.env):
#   GROQ_API_KEY      https://console.groq.com/keys
#   AGENTOPS_API_KEY  https://app.agentops.ai

{ inputs, pkgs, system, ... }:

{
  home.packages = [
    inputs.llama-fs.packages.${system}.default
  ];
}
