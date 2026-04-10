# Claude Code Guidelines — nixos-config

## User Preferences

- **Prefer TUIs over GUIs** whenever a well-maintained, aesthetic TUI exists. Before suggesting or implementing a GUI tool, check if a good TUI alternative is available in nixpkgs.

### Vetted TUI replacements (nixpkgs package in parentheses)

| Category | Use | nixpkgs |
|----------|-----|---------|
| Bluetooth | `bluetui` — Rust/ratatui, vim keys, 2x stars vs bluetuith | `bluetui` |
| WiFi | `wifitui` — Go/Bubble Tea, NM-native, actively maintained | `wifitui` |
| Network (fallback) | `nmtui` — official NM curses UI, zero-config | bundled in `networkmanager` |
| System monitor | `btop` — interactive, beautiful | `btop` |
| Audio mixer | `wiremix` — PipeWire-native TUI | `wiremix` |
| Music (Spotify) | `spotify-player` — full Spotify in terminal | `spotify-player` |
| Disk usage | `dua-cli` — fast parallel Rust TUI | `dua` |
| File manager | `yazi` (already in use) | `yazi` |

## Architecture

- NixOS flake-based config with home-manager as a NixOS module (single `nixos-rebuild switch`)
- Target machine: ASUS laptop, Intel i7 + NVIDIA RTX 4070 (Optimus PRIME hybrid), 3200x2000 display
- Desktop: Hyprland (Wayland)
- Theming: stylix handles GTK, Qt, fonts, colors globally — do not add manual theme overrides

## Development Workflow

- Test changes with `nix build .#nixosConfigurations.nixos.config.system.build.vm` before committing
- VM lives at `~/nixos-config/nixos.qcow2` (gitignored)
- Run VM: `result/bin/run-nixos-vm`
- nvim config lives in a separate repo (`vitorbborges/nvim-config`), pinned via `fetchFromGitHub` in `modules/user/nvim/nvim.nix`
- Update nvim pin: `cd ~/nixos-config/modules/user/nvim && ./update-nvim-auto.sh`

## NixOS-Specific Rules

- Mason cannot install binaries on NixOS — all LSP servers, formatters, linters must come from Nix (`home.packages` in `nvim.nix`)
- `useGlobalPkgs = true` is set — never add `nixpkgs.config.*` inside home-manager modules
- `allowUnfree` is set once in `flake.nix` only
- Prefer `pkgs.<package>` over `fetchFromGitHub` whenever the package exists in nixpkgs
