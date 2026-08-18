# Agent Guidelines — nixos-config

## Development Workflow

- Rebuild: `sudo nixos-rebuild switch --flake ~/nixos-config#desktop`
- Aliases (defined in `modules/user/zsh/zsh.nix`): `nr` rebuilds; `nrc` = `git add` + rebuild + commit + push (timestamp message)
- Deploy VPS: `sudo nixos-rebuild switch --target-host vps --flake ~/nixos-config#oci-vps`
- Validate without sudo: `nix build .#nixosConfigurations.desktop.config.system.build.toplevel --no-link`
- **New files must be `git add`ed before rebuilding** — Nix flakes only see git-tracked files; untracked files are invisible to the evaluator even with a dirty tree
- Test in VM: `nix build .#nixosConfigurations.desktop.config.system.build.vm && result/bin/run-nixos-vm`
- VM image: `~/nixos-config/nixos.qcow2` (gitignored)

---

## User Preferences

- TUIs are preferred for system utilities (file management, monitoring, audio, networking) — see table below.
- For media, communication, and productivity apps the user has settled on preferred desktop clients after testing TUI alternatives — don't second-guess those choices.
- Before suggesting a new tool, check whether a good TUI alternative exists in nixpkgs, but accept that some categories (email, music, photo management) already have settled desktop answers.

### Current tool choices

| Category | Use | nixpkgs | Type |
|----------|-----|---------|------|
| Bluetooth | `bluetui` — Rust/ratatui, vim keys | `bluetui` | TUI |
| WiFi | `wifitui` — Go/Bubble Tea, NM-native | `wifitui` | TUI |
| Network (fallback) | `nmtui` — official NM curses UI | bundled in `networkmanager` | TUI |
| System monitor | `btop` | `btop` | TUI |
| Audio mixer | `wiremix` — PipeWire-native | `wiremix` | TUI |
| Music (Spotify) | Spotify official desktop + spicetify | `spotify` + `spicetify-cli` | Desktop |
| Disk usage | `dua-cli` | `dua` | TUI |
| File manager | `yazi` | `yazi` | TUI |
| Email | Thunderbird | `thunderbird` | Desktop |
| Photo management | DigiKam | `digikam` | Desktop |

---

## Architecture

- NixOS flake-based config with home-manager as a NixOS module (single `nixos-rebuild switch`)
- Two hosts: `desktop` (ASUS Vivobook Pro 16X, Intel Core i9-13980HX + NVIDIA RTX 4070 Optimus PRIME, 3200x2000 HiDPI) and `oci-vps` (Oracle Cloud VPS — Vaultwarden, AdGuardHome, WireGuard)
- Desktop: Hyprland (Wayland) via UWSM
- Theming: stylix handles GTK, Qt, fonts, colors globally — do not add manual theme overrides

---

## Design Principles

### 1. Change Once, Apply Everywhere

All global variables live in the `let` block of `flake.nix` and are the **single source of truth**:

```nix
username = "vitor";
kbLayout = "us";
font     = "JetBrains Mono Nerd Font";
theme    = "catppuccin-mocha";   # change this → entire system rethemes
```

These flow to every module via two channels:
- `specialArgs` → NixOS system modules
- `home-manager.extraSpecialArgs` → all home-manager modules

**Rule:** If a value needs to be the same in more than one place, it belongs in `flake.nix`, not hardcoded in individual modules.

### 2. Stylix Is the Theming Layer — Never Bypass It

Stylix resolves `theme` to a base16 palette and injects colors/fonts into all enabled targets. Three legitimate patterns for consuming colors in modules:

**a) Let stylix handle it automatically** (preferred — zero config):
```nix
stylix.targets.zathura.enable = true;  # stylix.nix — done, no color config needed in zathura.nix
```

**b) CSS variables** — for waybar and other CSS-configured tools:
```css
/* style.css — stylix injects @base00..@base0F, never hardcode hex */
background: @base00;
color:      @base05;
border:     1px solid @base0D;
```

**c) Nix color expressions** — for tools that need colors as Nix strings (hyprlock, swaync):
```nix
{ config, ... }:
let
  c    = config.lib.stylix.colors.withHashtag;   # "#RRGGBB" strings
  font = config.stylix.fonts.monospace.name;
  sz   = toString config.stylix.fonts.sizes.applications;
in {
  # use c.base00, c.base05, etc.
  # for rgba: "rgba(${config.lib.stylix.colors.base00}cc)"
}
```

**Rule:** Never hardcode hex colors or font names outside `stylix.nix`. If stylix's auto-target isn't flexible enough, use pattern (c). Disable the auto-target (`stylix.targets.foo.enable = false`) only when taking manual control — document why.

### 3. Module Isolation — One Concern Per File

Each `.nix` file in `modules/user/` or `modules/system/` owns exactly one concern. Both directories use an **auto-import `default.nix`** that recursively picks up every `.nix` file — no manual import lists needed.

**Consequence:** Adding a new module = create the file, done. Removing a module = delete the file, done. Never add imports by hand in `default.nix`.

**How to decide where a setting belongs:**
- Affects system services, kernel, hardware → `modules/system/`
- Affects the user environment, dotfiles, programs → `modules/user/`
- Cross-cutting (e.g., MIME associations) → dedicated file (`xdg/xdg.nix`), not spread across modules

### 4. No Foreign Code Inline in Nix — Extract to Dedicated Files

Bash, CSS, Lua, TOML, and any other non-Nix code must never live inside Nix strings (`text = ''...''`). Put it in a sibling file and import it:

- **Plain content** (no Nix values needed): `builtins.readFile ./scripts/foo.sh`, `./style.css`
- **Content needing Nix values** (store paths, stylix colors): template file with `@placeholder@` tokens substituted at eval time:
  ```nix
  text = builtins.replaceStrings
    [ "@base00@" "@font@" ]
    [ c.base00 font ]
    (builtins.readFile ./style.css.in);
  ```
- **Caveat:** `builtins.replaceStrings` does NOT coerce derivations to strings — wrap them as `"${drv}"` in the replacement list (interpolation does the coercion).
- Conventions: scripts → `scripts/`; templates → `*.in` files; nvim Lua → `lua/`. Omit the shebang in `writeShellApplication` `text` (it adds one); keep `#!/usr/bin/env bash` for `home.file` sources.

### 5. Threading Flake Inputs Into Modules

External flake inputs (spicetify-nix, stylix, zen-browser, hyprland) are NOT available in modules by default. They must be threaded via `inputs` in `extraSpecialArgs`, then imported explicitly inside the module that needs them:

```nix
# modules/user/spicetify/spicetify.nix
{ inputs, pkgs, ... }:
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];
  programs.spicetify = {
    enable = true;
    # spicePkgs comes from the input, not from nixpkgs
    theme = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system}.themes.comfy;
  };
}
```

**Rule:** Inputs are explicit. If a module uses a flake input, declare `inputs` as a function argument and import its module/package directly. Never assume an input's packages are in `pkgs`.

### 6. Stable vs Unstable Packages

Most packages use `pkgs` (nixos-unstable). Use `pkgs-stable` only when a package has known instability on unstable or requires strict reproducibility (e.g., VSCodium). `pkgs-stable` is passed via `extraSpecialArgs` and available in any module that declares it as an argument.

```nix
{ pkgs, pkgs-stable, ... }:
{
  home.packages = [
    pkgs.ripgrep          # unstable — fine for most CLI tools
    pkgs-stable.vscodium  # stable — complex deps, reproducibility matters
  ];
}
```

### 7. useGlobalPkgs — No Duplicate nixpkgs Imports

`home-manager.useGlobalPkgs = true` is set. Home-manager shares the system's `nixpkgs` instance. **Consequences:**
- Never add `nixpkgs.config.*` inside home-manager modules — it has no effect and emits a warning
- `allowUnfree` is set once in `flake.nix` only
- `pkgs` in any home-manager module is the same `pkgs` as the system

### 8. Mason Cannot Install Binaries on NixOS

LSP servers, formatters, and linters must come from Nix, not Mason. Add them to `home.packages` in `modules/user/nvim/nvim.nix` (or `lsp.nix`). Mason's `:MasonInstall` will silently fail or produce broken binaries because NixOS has no FHS.

### 9. Skills Are Auto-Discovered — No Registration

Skills live in `modules/user/agents/skills/<name>/` and are materialized to `~/.claude/skills/` by `modules/user/agents/skills.nix` (recursive `home.file`). Adding a skill = create the directory with `SKILL.md`, `git add`, rebuild. No import list to edit. Follow Anthropic's skill best practices: gerund `name`, third-person `description` with triggers, body <500 lines, progressive disclosure via `references/`.

---

## NixOS-Specific Rules

- `allowUnfree = true` is set once in `flake.nix` — never repeat it in modules
- Prefer `pkgs.<package>` over `fetchFromGitHub` whenever the package exists in nixpkgs
- SSH known hosts go in `modules/system/ssh.nix` via `programs.ssh.knownHosts` — never add them manually to `~/.ssh/known_hosts` (non-reproducible)
- SSH agent is `services.ssh-agent` (systemd user socket) — not gnome-keyring, not `programs.ssh.startAgent`
- MIME associations belong in `modules/user/xdg/xdg.nix` — not scattered across app modules
