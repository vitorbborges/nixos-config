# NixOS Config TODO

Priority order: Bugs → Structural → Migration → Program swaps

---

## Structural

- [ ] **`hosts/` abstraction** — add `hosts/nixos/` to isolate per-machine specifics (hardware-configuration, hostname, monitor layout, PRIME bus IDs); do after Hyprland migration is complete

- [ ] **Audit `catppuccin` flake input** — imported in `flake.nix` but not visibly used in any module. Either wire it up (e.g., as a nixvim colorscheme source) or remove it to keep the lock file lean.

---

## Flake Health

- [ ] **`autoUpgrade` only tracks 2 of 8+ inputs** — nixpkgs and home-manager are updated; hyprland, nixvim, zen-browser, catppuccin, spicetify-nix, stylix, and nixpkgs-stable are pinned forever unless you run `nix flake update` manually. Decide: do you want all inputs to drift together or pin non-critical ones?

---

## Hardware / NVIDIA

Currently the config has PRIME entirely disabled (commented out). This section captures the full sequence for proper Optimus setup.

- [ ] **Enable NVIDIA open source kernel module** — `modules/system/nvidia/nvidia.nix`
  RTX 4070 is Ada Lovelace (Turing+). NixOS wiki now recommends `hardware.nvidia.open = true`
  for Turing and newer. Required since driver 560 where auto-detection was removed.
  Test in VM first (VRAM behavior may differ), then set on baremetal.

- [ ] **Enable `powerManagement.enable = true`** (stable, not finegrained) — saves VRAM state to
  `/tmp/` on suspend so PRIME doesn't corrupt the display on wake. Required for reliable
  suspend/resume on hybrid laptops. `finegrained` (RTD3 idle power-off) is still experimental
  and has known issues on some 4070 configs — leave `false` for now.

- [ ] **Add PRIME BusIDs and choose a GPU mode** — current config has BusIDs commented out.
  Confirmed from `lspci`: `intelBusId = "PCI:0:2:0"`, `nvidiaBusId = "PCI:1:0:0"`.
  Three choices:
  - **offload** (recommended for battery): iGPU drives display, NVIDIA activated per-app via
    `nvidia-offload <cmd>` or `DRI_PRIME=1`. Lowest power draw.
  - **sync** (max perf): NVIDIA always drives display. Higher power, best compatibility.
  - **reverse-sync** (Wayland-friendly offload): render on NVIDIA, copy to iGPU for display.
    Often best for Hyprland + PRIME.

- [ ] **`programs.envycontrol`** — cross-distro CLI to switch integrated/hybrid/nvidia modes
  (requires reboot). Simpler than supergfxctl, works without ASUS-specific daemons.
  Evaluate before supergfxctl if ASUS tooling feels heavy.

- [ ] **`supergfxctl` + `asusctl`** (ASUS-native alternative) — `services.supergfxd.enable = true`
  enables GPU mode switching without reboot in some cases. `programs.rog-control-center` adds
  the ASUS GUI for fan curves and power profiles. Heavier dependency chain but more integrated
  with the laptop's EC firmware. Pairs with `services.asusd.enable = true` (fan + keyboard LEDs).

---

## Migration: Hyprland

After each round: `nix build .#nixosConfigurations.nixos.config.system.build.vm`, boot, verify.

### Round 2 — Daily usability (remaining)

- [ ] **Wallpaper picker** — `$mod+SHIFT+W` opens fuzzel `--dmenu` mode to browse
  `~/Media/Pictures/Wallpapers/` with preview (pipe through `swww img` or `wallpaper-switch`).
  Requires fuzzel configured first.
- [ ] **XDG portal** — verify `xdg-desktop-portal-hyprland` is active; `programs.hyprland.enable`
  with `portalPackage` should wire it up automatically, but confirm with
  `systemctl --user status xdg-desktop-portal-hyprland`.
- [ ] **GNOME Keyring** — verify PAM unlock works; update `gnome-keyring.nix` when migrating away
  from SDDM: replace `security.pam.services.sddm.enableGnomeKeyring` with greetd equivalent
  (`security.pam.services.greetd.enableGnomeKeyring = true`).

### Round 3 — Theming & extras

- [ ] **Stylix full wiring** — verify GTK, Qt, cursor, waybar, hyprlock themed; drop manual overrides.
  Enable `stylix.targets.fuzzel.enable`, `stylix.targets.waybar.enable`,
  `stylix.targets.swaync.enable` once each tool is installed.
- [ ] **Drop AGS** — only used for `Super+A` overview; AGS v1 deprecated.
  Replace with `hyprexpo` plugin (Hyprland first-party workspace overview):
  `wayland.windowManager.hyprland.plugins = [ pkgs.hyprlandPlugins.hyprexpo ]`
  and bind `$mod, A, hyprexpo:expo, toggle`.
- [ ] **Network tray** — `nm-applet --indicator` exec-once; or use waybar's network module
  (no tray icon needed if waybar is fully configured).
- [ ] **Audio mixer** — `wiremix` already in packages; add kitty keybind (`$mod+S` = `kitty -e wiremix`).
- [ ] **System monitor** — `btop` already available; add keybind (`$mod+T` or similar).
- [ ] **Disk usage** — `dua` (dua-cli); add keybind or yazi integration.
- [ ] **wlogout** — power menu; keybind `CTRL+ALT+P`. `wlogout` is in nixpkgs; configure
  `programs.wlogout` in home-manager. Style with stylix or manual CSS for matching look.
- [ ] **Screen recording** — add `wl-screenrec` (GPU-accelerated, Wayland-native, low overhead)
  or `wf-recorder`; bind `$mod+SHIFT+R` to toggle recording with output to `~/Media/Videos/`.
- [ ] **ActivityWatch** — verify works in VM; `services.activitywatch` already configured.
  Check if awatcher overlay version (0.3.3) is current with upstream.

### Round 4 — Hyprland config itself

- [ ] **Monitor config** — eDP-1: 3200x2000 @ 2.0 scale 120Hz; HDMI-A-2: 1920x1080 @ 60Hz.
  Current config uses `preferred,auto,1` (no scale) which will look tiny on 3200x2000.
  Set `monitor = [ "eDP-1,3200x2000@120,0x0,2" "HDMI-A-2,1920x1080@60,1600x0,1" ]`.
- [ ] **Input settings** — repeat rate 50/300ms, numlock on, touchpad: natural scroll + tap-to-click.
  Current config has `natural_scroll = false` — flip to `true` for laptop.
- [ ] **Keybinds** — `$mod+R`=fuzzel, `CTRL+ALT+L`=lock (already set), `CTRL+ALT+P`=wlogout.
  Consider switching `$mod` from `ALT` to `SUPER` — ALT conflicts with many terminal apps and
  web browser shortcuts; SUPER is the standard Hyprland modifier.
- [ ] **Window rules** — floating rules for common dialogs (`pavucontrol`, `nm-applet`,
  file-picker dialogs); workspace assignments (browser on 2, code on 3, media on 5);
  opacity rules for inactive windows.
- [ ] **Decorations** — rounding 10px, blur size 6 passes 2, dim inactive 0.1.
  Current: rounding 5, blur size 3 passes 1 — bump these for a more polished look.
- [ ] **Environment variables** — `HYPRCURSOR_THEME=Bibata-Modern-Ice` size 24 (already set in
  stylix cursor config; verify hyprland picks it up or add to `env` section explicitly).
- [ ] **`wallpaper-switch`: use `nh os switch` instead of `sudo nixos-rebuild switch`** —
  `nh` is already in `home.packages`; `nh os switch --flake /path` is a drop-in replacement
  that adds generation diffing and build progress. When done, the `security.sudo.extraRules`
  NOPASSWD for `nixos-rebuild` can be narrowed or removed.

---

## Neovim — Remaining

- [ ] **GitHub Copilot** — inline ghost text (`copilot.lua` via blink-cmp source) + chat UI
  (`CopilotChat.nvim`). Wire into blink-cmp as an extra source:
  `sources.default = [ "lsp" "path" "snippets" "buffer" "copilot" ]` and add
  `programs.nixvim.plugins.copilot-lua.enable = true`. The VSCodium config already has
  `github.copilot-chat` — this mirrors that for terminal nvim.

- [ ] **Missing LSP servers** — modules/user/nvim/lsp.nix currently has lua, python, C/C++, nix.
  Add:
  - `r_language_server` — R module (`modules/user/development-tools/r.nix`) exists but no LSP
  - `bashls` (`bash-language-server`) — shell scripts are common in this config
  - `ts_ls` — TypeScript/JavaScript for web work

- [ ] **Cleanup** — remove `nvim-update` / `nu` zsh aliases (no more `fetchFromGitHub` pin);
  archive `vitorbborges/nvim-config` GitHub repo; remove `update-nvim-auto.sh` mention from CLAUDE.md.

---

## Development Workflow

- [ ] **`direnv` + `nix-direnv`** — per-project devshells without polluting the system environment.
  Add to home-manager:
  ```nix
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;  # faster nix-direnv integration with caching
    enableZshIntegration = true;
  };
  ```
  Pairs with `nix.settings.keep-outputs = true` in nix-settings.nix (see Flake Health).

- [ ] **`nix-index-database`** — `command-not-found` handler that suggests `nix-shell -p <pkg>`
  when you type a missing command. Avoids the slow `nix search` workflow.
  Use the pre-built `nix-index-database` flake input (no indexing needed):
  ```nix
  inputs.nix-index-database.url = "github:nix-community/nix-index-database";
  # in home-manager:
  imports = [ inputs.nix-index-database.hmModules.nix-index ];
  programs.nix-index-database.comma.enable = true;  # also enables comma (,)
  ```

- [ ] **Git SSH commit signing** — modern alternative to GPG signing (2025 standard).
  Add to `modules/user/git/git.nix`:
  ```nix
  programs.git.settings = {
    gpg.format = "ssh";
    user.signingKey = "~/.ssh/id_ed25519.pub";  # or path to key
    commit.gpgsign = true;
    tag.gpgsign = true;
  };
  ```

---

## Battery / Power

- [ ] **Battery optimization** — decision matrix for Intel + NVIDIA Optimus laptop:
  - `services.power-profiles-daemon.enable = true` — lightweight, integrates with waybar's
    `custom/power-profile` or `battery` module; controlled by `powerprofilesctl`; conflicts with tlp/auto-cpufreq.
  - `services.auto-cpufreq.enable = true` — CPU governor tuning based on AC/battery state;
    more aggressive than PPD; can coexist with PRIME offload; conflicts with power-profiles-daemon.
  - `services.tlp.enable = true` — most comprehensive but heavy; not needed if using PRIME offload
    + PPD.
  **Recommendation**: `power-profiles-daemon` + PRIME offload is the lowest-friction choice for
  Hyprland + NVIDIA. Add waybar module showing power profile (saver/balanced/performance) with
  click-to-cycle.

---

## Program Swaps

- [ ] **Remove `timeshift`** — redundant on NixOS; generations + `nh` handle rollback.
  Remove from `modules/system/packages.nix`.

- [ ] **Remove `gparted`** from `modules/system/packages.nix` — GTK GUI contradicts TUI preference;
  replace with CLI workflow (`parted`, `lsblk`, `fdisk`). Keep `gparted` only as opt-in if needed
  for a complex partition operation.

- [ ] **Replace `conda` with `uv` + nix dev shells** — `uv` already installed and configured.
  `conda` needs FHS paths and conflicts with NixOS's nix store layout. Migrate existing conda
  environments to `uv venv` + `uv pip install`. Remove `conda` from python.nix once migrated.
  Dev shell template:
  ```nix
  # per-project shell.nix or flake devShell
  { pkgs }: pkgs.mkShell {
    packages = with pkgs; [ python312 uv ruff pyright ];
  }
  ```

- [ ] **Replace SDDM with `greetd` + `tuigreet`** — SDDM pulls X.org server; `greetd` is X-free,
  lighter, and purpose-built for Wayland. Full config for `modules/system/hyprland/hyprland.nix`:
  ```nix
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = lib.concatStringsSep " " [
          "${pkgs.greetd.tuigreet}/bin/tuigreet"
          "--time" "--remember" "--remember-user-session" "--asterisks"
          "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
        ];
        user = "greeter";
      };
    };
  };
  ```
  When switching: (1) disable `services.displayManager.sddm.*`, (2) update `gnome-keyring.nix`
  to use `security.pam.services.greetd.enableGnomeKeyring = true`, (3) remove
  `sddm-astronaut` package from system packages.

- [ ] **Replace `oh-my-zsh`** with `starship` + direct plugin loading — `oh-my-zsh` with the
  "fox" theme adds ~300ms to zsh startup. Already have: `zsh-vi-mode`, `fzf-tab`,
  `zsh-nix-shell`, `zoxide`, `atuin`, `syntaxHighlighting`, `autosuggestion` — these are
  enough without oh-my-zsh. Add `programs.starship.enable = true` (stylix themes it) and
  drop `oh-my-zsh` block. The `dotenv`, `last-working-dir`, `sudo`, `git-auto-fetch` plugins
  can be replaced by: `direnv` (dotenv+devshells), `zoxide` (last-working-dir equivalent),
  a `bindkey` for sudo (Esc+Esc), and a zsh hook for git fetch.

- [ ] **`syncthing.tray.enable = false`** — `tray.enable = true` spawns `syncthing-gtk` (a GTK
  GUI). Prefer the web UI at `localhost:8384` or a waybar custom module showing sync status
  via `syncthing-tray` (CLI) or just leave it headless.

---

## Baremetal Readiness

Items that are fine for VM but must be fixed before running on real hardware.

- [ ] **Remove `initialPassword = "nixos"`** from both `users.users.${username}` and
  `users.users.root` in `modules/system/users.nix`. For baremetal, use `hashedPasswordFile`
  pointing to a file outside the nix store (managed by `sops-nix` or `agenix`), or set the
  password interactively via `passwd` after first boot.

- [ ] **Change hostname** — `networking.hostName = "nixos"` (generic). Pick a real name and
  update `flake.nix`'s `nixosConfigurations.nixos` key to match.

- [ ] **Verify EFI mount point** — `boot.loader.efi.efiSysMountPoint = "/boot/efi"` is the
  default but some ASUS laptops mount the ESP at `/boot` directly. Check `hardware-configuration.nix`
  on the actual machine.

- [ ] **Remove `security.sudo.extraRules` NOPASSWD for nixos-rebuild** once `wallpaper-switch`
  is updated to use `nh os switch` (no sudo needed for nh with the right group membership).

- [ ] **Verify PRIME BusIDs on actual hardware** — the `lspci` values in nvidia.nix comments
  (`0000:00:02.0`, `0000:01:00.0`) need to match the baremetal output. Run
  `lspci | grep -E 'VGA|3D'` and confirm IDs before enabling PRIME.

- [ ] **Monitor config** — the placeholder `",preferred,auto,1"` will use 1:1 scale on a
  3200x2000 display, making everything tiny. Must set explicit scale before first use.
