# NixOS Config TODO

---

## Structural

- [ ] **`hosts/` abstraction** — add `hosts/vivobook/` to isolate per-machine specifics (hardware-configuration, hostname, monitor layout, PRIME bus IDs)

- [ ] **Audit `catppuccin` flake input** — imported in `flake.nix` but not used in any module. Wire it up or remove it.

---

## Flake Health

- [ ] **`autoUpgrade` only tracks 2 of 8+ inputs** — nixpkgs and home-manager are updated; hyprland, nixvim, zen-browser, catppuccin, spicetify-nix, stylix, nixpkgs-stable are pinned forever. Decide: all inputs drift together or pin non-critical ones?

---

## Hardware / NVIDIA

- [ ] **Enable NVIDIA open source kernel module** — RTX 4070 is Turing+; NixOS wiki recommends `hardware.nvidia.open = true` since driver 560. Test in VM first.

- [ ] **Enable `powerManagement.enable = true`** (stable, not finegrained) — saves VRAM state on suspend; required for reliable suspend/resume on hybrid laptops.

- [ ] **Add PRIME BusIDs and choose GPU mode** — BusIDs confirmed: `intelBusId = "PCI:0:2:0"`, `nvidiaBusId = "PCI:1:0:0"`. Choose: offload (battery), sync (perf), or reverse-sync (Wayland-friendly).

- [ ] **`programs.envycontrol`** — CLI to switch integrated/hybrid/nvidia modes. Evaluate before supergfxctl.

- [ ] **`supergfxctl` + `asusctl`** — ASUS-native GPU switching + fan curves + keyboard LEDs. Heavier but more integrated with EC firmware.

---

## Migration: Hyprland

### Round 2 — remaining

- [ ] **Wallpaper picker** — `$mod+SHIFT+W` opens fuzzel `--dmenu` over `~/Media/Pictures/Wallpapers/` piped to `wallpaper-switch`.

- [ ] **XDG portal** — confirm `xdg-desktop-portal-hyprland` is active: `systemctl --user status xdg-desktop-portal-hyprland`.

### Round 3 — extras

- [ ] **Drop AGS** — AGS v1 deprecated. Replace `Super+A` overview with hyprexpo: `pkgs.hyprlandPlugins.hyprexpo`, bind `$mod, A, hyprexpo:expo, toggle`.

- [ ] **Network tray** — `nm-applet --indicator` in exec-once, or rely solely on waybar network module.

- [ ] **Audio mixer keybind** — `$mod+S` = `kitty -e wiremix` (wiremix already in packages).

- [ ] **System monitor keybind** — `$mod+T` = `kitty -e btop`.

- [ ] **Disk usage** — `dua` already available; add yazi keybind or hyprland bind.

- [ ] **wlogout** — power menu on `CTRL+ALT+P`; `programs.wlogout` in home-manager.

- [ ] **Screen recording** — `wl-screenrec` (GPU-accelerated); bind `$mod+SHIFT+R` to toggle, output to `~/Media/Videos/Screencasts/`.

- [ ] **ActivityWatch** — verify `services.activitywatch` works on baremetal; check if awatcher overlay (0.3.3) is current.

### Round 4 — remaining

- [ ] **Window rules** — floating for common dialogs (`pavucontrol`, file-picker); workspace assignments (browser→2, code→3, media→5); opacity for inactive windows.

- [ ] **`wallpaper-switch`: use `nh os switch`** — replace `sudo nixos-rebuild switch` in `wallpaper-switch.sh`. Once done, remove the NOPASSWD `security.sudo.extraRules` in `users.nix`.

---

## Neovim

- [ ] **GitHub Copilot** — `programs.nixvim.plugins.copilot-lua.enable = true`; add as blink-cmp source.

- [ ] **Missing LSP servers** — add to `lsp.nix`: `r_language_server`, `bashls`, `ts_ls`.

- [ ] **Cleanup** — remove `nvim-update`/`nu` zsh aliases; archive `vitorbborges/nvim-config` repo.

---

## Development Workflow

- [ ] **`direnv` + `nix-direnv`** — per-project devshells. `programs.direnv.enable = true; nix-direnv.enable = true`.

- [ ] **`nix-index-database`** — `command-not-found` handler via pre-built index; also enables `comma` (`,`).

---

## Battery / Power

- [ ] **Battery optimization** — recommended: `services.power-profiles-daemon.enable = true` + PRIME offload. Add waybar power-profile module (click to cycle saver/balanced/performance).

---

## Program Swaps

- [ ] **Remove `timeshift`** — redundant on NixOS; NixOS generations handle rollback.

- [ ] **Remove `gparted`** — contradicts TUI preference; use `parted`/`lsblk`/`fdisk`.

- [ ] **Replace `conda` with `uv` + nix devshells** — conda conflicts with NixOS FHS. Migrate envs to `uv venv`, then remove conda from `python.nix`.

- [ ] **`syncthing.tray.enable = false`** — spawns GTK GUI; prefer web UI at `localhost:8384`.

---

## Baremetal — remaining

- [ ] **Remove `security.sudo.extraRules` NOPASSWD for nixos-rebuild** — blocked on wallpaper-switch → `nh os switch` migration above.

- [ ] **Verify PRIME BusIDs on baremetal before enabling PRIME** — run `lspci | grep -E 'VGA|3D'` and confirm `0:2:0` / `1:0:0` match before uncommenting PRIME config.
