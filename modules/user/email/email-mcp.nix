{ pkgs, ... }:

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

  home.file.".config/email-mcp/config.json".text = builtins.toJSON {
    host = "smtp.terra.com.br";
    port = 465;
    security = "ssl";
    username = "vitorbborges@terra.com.br";
    from = "Vitor Bandeira Borges <vitorbborges@terra.com.br>";
    password_file = "/run/secrets/smtp_password";
  };
}
