{ ... }:

{
  programs.nixvim.plugins = {

    # blink-cmp-copilot: Copilot source for blink-cmp; auto-enables copilot-lua
    blink-cmp-copilot.enable = true;

    copilot-lua.settings = {
      # Suggestions come through blink-cmp completion menu, not inline ghost text
      suggestion.enabled = false;
      panel.enabled = false;
    };

    blink-cmp.settings.sources.providers.copilot = {
      name   = "copilot";
      module = "blink-cmp-copilot";
      score_offset = 100;  # rank above LSP suggestions
      async = true;
    };
  };
}
