# Claude Code Guidelines — nixos-config

## User Preferences

- **Prefer TUIs over GUIs** whenever a well-maintained, aesthetic TUI exists. Before suggesting or implementing a GUI tool, check if a good TUI alternative is available in nixpkgs.

### Vetted TUI replacements (nixpkgs package in parentheses)

| Category | Use | nixpkgs |
|----------|-----|---------|
| Bluetooth | `bluetui` — Rust/ratatui, vim keys | `bluetui` |
| WiFi | `wifitui` — Go/Bubble Tea, NM-native | `wifitui` |
| Network (fallback) | `nmtui` — official NM curses UI | bundled in `networkmanager` |
| System monitor | `btop` | `btop` |
| Audio mixer | `wiremix` — PipeWire-native | `wiremix` |
| Music (Spotify) | `spotify-player` | `spotify-player` |
| Disk usage | `dua-cli` | `dua` |
| File manager | `yazi` (in use) | `yazi` |

---

## Architecture

- NixOS flake-based config with home-manager as a NixOS module (single `nixos-rebuild switch`)
- Target machine: ASUS Vivobook, Intel i7 + NVIDIA RTX 4070 (Optimus PRIME hybrid), 3200x2000 HiDPI display
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

### 4. Threading Flake Inputs Into Modules

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

### 5. Stable vs Unstable Packages

Most packages use `pkgs` (nixos-unstable). Use `pkgs-stable` only when a package has known instability on unstable or requires strict reproducibility (e.g., RStudio, VSCodium). `pkgs-stable` is passed via `extraSpecialArgs` and available in any module that declares it as an argument.

```nix
{ pkgs, pkgs-stable, ... }:
{
  home.packages = [
    pkgs.ripgrep          # unstable — fine for most CLI tools
    pkgs-stable.rstudio   # stable — complex deps, reproducibility matters
  ];
}
```

### 6. useGlobalPkgs — No Duplicate nixpkgs Imports

`home-manager.useGlobalPkgs = true` is set. Home-manager shares the system's `nixpkgs` instance. **Consequences:**
- Never add `nixpkgs.config.*` inside home-manager modules — it has no effect and emits a warning
- `allowUnfree` is set once in `flake.nix` only
- `pkgs` in any home-manager module is the same `pkgs` as the system

### 7. Mason Cannot Install Binaries on NixOS

LSP servers, formatters, and linters must come from Nix, not Mason. Add them to `home.packages` in `modules/user/nvim/nvim.nix` (or `lsp.nix`). Mason's `:MasonInstall` will silently fail or produce broken binaries because NixOS has no FHS.

---

## Development Workflow

- Rebuild: `sudo nixos-rebuild switch --flake ~/nixos-config#vivobook`
- **New files must be `git add`ed before rebuilding** — Nix flakes only see git-tracked files; untracked files are invisible to the evaluator even with a dirty tree
- Test in VM: `nix build .#nixosConfigurations.vivobook.config.system.build.vm && result/bin/run-nixos-vm`
- VM image: `~/nixos-config/nixos.qcow2` (gitignored)

---

## NixOS-Specific Rules

- `allowUnfree = true` is set once in `flake.nix` — never repeat it in modules
- Prefer `pkgs.<package>` over `fetchFromGitHub` whenever the package exists in nixpkgs
- SSH known hosts go in `modules/system/ssh.nix` via `programs.ssh.knownHosts` — never add them manually to `~/.ssh/known_hosts` (non-reproducible)
- SSH agent is `services.ssh-agent` (systemd user socket) — not gnome-keyring, not `programs.ssh.startAgent`
- MIME associations belong in `modules/user/xdg/xdg.nix` — not scattered across app modules
