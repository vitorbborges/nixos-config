---
name: theming-nixos-with-stylix
description: "Adds or fixes theming for an application in this stylix-managed NixOS config. Use when the user asks to theme a new tool, fix an app that doesn't match the global theme, change the global theme variable, or migrate an app's hardcoded colors to stylix."
---

# Theming with Stylix

Stylix is the single theming layer: it resolves the `theme` variable in `flake.nix` to a base16 palette and injects colors/fonts into every enabled target. All theming work follows one of three patterns; pick the first one that works and never hardcode.

## The decision tree

1. **Auto-target exists?** → enable it in `modules/user/stylix/stylix.nix` under `stylix.targets`. Zero config. Always try this first.
2. **Tool is CSS-configured?** (waybar, swaync, thunderbird userChrome, wlogout) → pattern B.
3. **Tool needs colors as Nix strings?** (hyprlock, swaync settings, herdr TOML, opencode theme JSON) → pattern C.

## Pattern A — let stylix do it

```nix
stylix.targets.zathura.enable = true;  # done — no color config in zathura.nix
```

Check the current targets list in `modules/user/stylix/stylix.nix` before adding a new one. If a target is disabled with `enable = false`, read the comment — it usually says which module took manual control and why (e.g., hyprlock, spicetify, hyprpaper).

## Pattern B — CSS with stylix variables (preferred for CSS tools)

Stylix injects `@base00`..`@base0F` as CSS variables. Write plain CSS using them:

```css
/* style.css — never hardcode hex */
background: @base00;
color:      @base05;
border:     1px solid @base0D;
```

Wire it with `lib.mkAfter (builtins.readFile ./style.css)` for merged styles (waybar) or a plain assignment for owned styles (swaync).

## Pattern C — Nix color expressions

For tools that need color values inside Nix strings:

```nix
{ config, ... }:
let
  c = config.lib.stylix.colors.withHashtag;  # "#RRGGBB" strings
in {
  # use c.base00 .. c.base0F
}
```

For rgba (e.g., GTK3 CSS which lacks 8-digit hex), convert hex with a helper or pre-compute in `builtins.replaceStrings`:
```nix
rgba = hex: alpha:
  let
    r = lib.fromHexString (builtins.substring 0 2 hex);
    g = lib.fromHexString (builtins.substring 2 2 hex);
    b = lib.fromHexString (builtins.substring 4 2 hex);
  in "rgba(${toString r}, ${toString g}, ${toString b}, ${toString alpha})";
```

## Template workflow (extracting CSS/TOML that needs stylix values)

Per the repo's no-inline-code rule, styled content lives in `*.in` template files:

1. Create `style.css.in` with `@base00@`..`@base0F@`, `@font@`, `@fontSize@` placeholders.
2. Substitute at eval time:

```nix
text = builtins.replaceStrings
  [ "@base00@" "@base01@" "@font@" ]
  [ c.base00 c.base01 font ]
  (builtins.readFile ./style.css.in);
```

Caveat: `builtins.replaceStrings` does NOT coerce derivations — wrap store paths as `"${drv}"` in the replacement list.

## The global theme switch

`theme = "catppuccin-mocha";` in the `let` block of `flake.nix` — changing this rethemes the whole system. Note the OLED override in `stylix.nix` (base00/base01 forced for true-black) survives theme switches.

## Non-negotiable rules

- Never hardcode a hex color or font name outside `modules/user/stylix/stylix.nix`.
- If you disable an auto-target to take manual control, document why in the comment.
- After any theming change: `nix build .#nixosConfigurations.desktop.config.system.build.toplevel --no-link` and confirm no unsubstituted `@baseXX@` placeholders remain in the built config.

## Output format

Report which pattern you used, the files changed, and the build result. If the tool has no stylix target and no CSS hook, say so instead of inventing one.
