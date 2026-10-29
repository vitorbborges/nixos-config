{ config, pkgs, ... }:

let
  email-mcp = pkgs.writeShellApplication {
    name = "email-mcp";
    runtimeInputs = [ pkgs.python3 ];
    text = ''
      exec python3 ${./email_mcp.py} "$@"
    '';
  };
in
{
  # SMTP config for the email MCP server. The password is the only secret and
  # lives in sops; see hosts/desktop/secrets.nix. Editing it:
  #   sops hosts/desktop/secrets.yaml
  home.packages = [ email-mcp pkgs.sops ];

  # opencode-quota rewrites the global opencode.jsonc on startup and drops
  # unknown keys, so the MCP entry and permission live in this extra config.
  home.file.".config/opencode/email-mcp.json".text = builtins.toJSON {
    mcp.email = {
      type = "local";
      command = [ "email-mcp" ];
      enabled = true;
    };
    permission.email_send_email = "ask";
  };

  programs.zsh.sessionVariables.OPENCODE_CONFIG =
    "${config.home.homeDirectory}/.config/opencode/email-mcp.json";

  home.file.".config/email-mcp/config.json".text = builtins.toJSON {
    host = "smtp.terra.com.br";
    port = 465;
    security = "ssl";
    username = "vitorbborges@terra.com.br";
    from = "Vitor Bandeira Borges <vitorbborges@terra.com.br>";
    password_file = "/run/secrets/smtp_password";
  };
}
