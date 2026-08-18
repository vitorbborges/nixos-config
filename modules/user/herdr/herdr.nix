{ pkgs, config, inputs, ... }:

let
  c = config.lib.stylix.colors.withHashtag;
in
{
  home.packages = [ inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default ];

  # herdr's opencode integration plugin (extracted from herdr v0.8.0 via
  # `herdr integration install opencode`, HERDR_INTEGRATION_VERSION=9).
  # Reports opencode session IDs + lifecycle state to herdr so panes are
  # resumed with `opencode --session <id>` after a reboot/server restart
  # (native agent session restore, see [session] resume_agents_on_restore).
  # Re-extract after bumping the herdr flake input.
  xdg.configFile."opencode/plugins/herdr-agent-state.js".source = ./herdr-agent-state.js;

  # Self-healing for panes sharing one session (herdr dedupes native restore).
  xdg.configFile."herdr/pair-restore.zsh".source = ./scripts/pair-restore.zsh;

  # TOML lives in ./config.toml.in with @placeholder@ tokens substituted
  # at eval time from stylix colors.
  xdg.configFile."herdr/config.toml".text = builtins.replaceStrings
    [ "@base00@" "@base01@" "@base02@" "@base03@" "@base04@" "@base05@" "@base08@" "@base09@" "@base0A@" "@base0B@" "@base0C@" "@base0D@" "@base0E@" ]
    [ c.base00 c.base01 c.base02 c.base03 c.base04 c.base05 c.base08 c.base09 c.base0A c.base0B c.base0C c.base0D c.base0E ]
    (builtins.readFile ./config.toml.in);

  # Auto-attach to the persistent herdr session on interactive shell start,
  # unless already inside one (HERDR_ENV) or in a non-interactive shell
  # (e.g. a scripted SSH command) — avoids nested-launch and breaking
  # non-interactive tooling.
  programs.zsh.initContent = ''
    if [[ -n "$HERDR_ENV" ]]; then
      source ${config.xdg.configHome}/herdr/pair-restore.zsh
    fi
    if [[ -z "$HERDR_ENV" && $- == *i* ]]; then
      exec herdr
    fi
  '';
}
