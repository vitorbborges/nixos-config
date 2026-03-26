# NixOS Config TODO

Priority order: Bugs → Redundant packages → Structural → Missing components → Program swaps

---

## Redundant Packages

`programs.X.enable = true` already installs the package — these `home.packages` entries are pure duplication:

- [ ] `nvim.nix` — remove `git`, `curl`, `wget` (system-wide or covered elsewhere)

---

## "Change One Place" Violations

- [ ] **`username` hardcoded in 4+ places** — add `let username = "vitorbborges";` in `flake.nix`, pass via `specialArgs`
- [ ] **Keyboard layout defined 3 times** — `configuration.nix`, `system/hyprland/hyprland.nix`, `user/hyprland/hyprland.nix`. Single variable via `specialArgs`.
- [ ] **SDDM resolution hardcoded to 1920x1080** — monitor is 3200x2000; fix in `system/hyprland/hyprland.nix`
- [ ] **`font`/`fontPkg` specialArgs** — vestigial; stylix manages fonts globally. Remove after fixing font duplication.
- [ ] **`system.autoUpgrade.flake` wrong path** — hardcoded `/home/vitorbborges/.dotfiles`; should be `~/nixos-config`

---

## Structural / Architecture Issues

- [ ] **`system/fonts.nix` sets JetBrains Mono as serif/sans-serif** — wrong; contradicts stylix which correctly uses DejaVu
- [ ] **Duplicate font installation** — `modules/user/fonts.nix` and `modules/system/fonts.nix` both install same nerd font; remove `modules/user/fonts.nix`
- [ ] **`spicetify-nix` missing `inputs.nixpkgs.follows`** — brings own nixpkgs copy, inflating closure
- [ ] **Auto-import in `default.nix` is non-deterministic** — import order not guaranteed; switch to explicit sorted list
- [ ] **`configuration.nix` too fat** — contains boot, networking, locale, users, shell, Nix settings, auto-upgrade, hardware maintenance; split into focused `modules/system/` files
- [ ] **No `hosts/` abstraction** — everything assumes one machine; add `hosts/nixos/` so per-machine specifics (hardware, hostname, username, timezone) are isolated from shared modules. Do this after migration is complete.

---

## Migration: Ubuntu Hyprland → NixOS

Audited Ubuntu setup (JaKooLit dots). Migrate component by component.
After each round: `nix build .#...vm`, boot, verify, then continue.

### Round 1 — Critical (system unusable without these)

- [ ] **Audio** — `services.pipewire` + wireplumber; zero sound without it
- [ ] **Bluetooth** — `hardware.bluetooth.enable` + `bluetuith` (TUI, replaces blueman GUI)
- [ ] **Wallpaper daemon** — `swww` package + `exec-once` in hyprland; screen blank without it
- [ ] **Idle management** — `programs.hypridle`: 9min notify → 10min lock → 11min DPMS off
- [ ] **Lock screen** — `programs.hyprlock`: blur background, time, date, password input
- [ ] **Clipboard** — `wl-clipboard` + `cliphist`; exec-once to watch text + image clipboard

### Round 2 — Daily usability

- [ ] **Notifications** — `services.swaync`; best Hyprland integration
- [ ] **App launcher** — replace `rofi` with `fuzzel`; rofi is X11-wrapped, fuzzel is Wayland-native
- [ ] **Status bar** — `programs.waybar` with battery, clock, cpu, network, audio, tray modules
- [ ] **XDG portal** — `xdg-desktop-portal-hyprland` system service; needed for screen sharing, file picker
- [ ] **Polkit agent** — `security.polkit.enable` + polkit authentication agent exec-once
- [ ] **GNOME Keyring** — already in `system/gnome-keyring.nix`; verify PAM unlock works in VM

### Round 3 — Theming & extras

- [ ] **Stylix full wiring** — verify GTK, Qt, cursor, waybar, hyprlock all themed via stylix; drop any remaining manual overrides
- [ ] **Drop AGS** — only used for `Super+A` overview; AGS v1 deprecated, not worth complexity
- [ ] **Network tray** — `nm-applet --indicator` exec-once; `nmtui` (bundled in networkmanager) for TUI management
- [ ] **Audio mixer** — `wiremix` TUI PipeWire mixer; keybind to open in kitty
- [ ] **System monitor** — `btop` TUI; keybind to open in kitty
- [ ] **Disk usage** — `dua` (dua-cli) fast parallel Rust TUI
- [ ] **wlogout** — power menu; add keybind `CTRL+ALT+P`
- [ ] **ActivityWatch** — already in config (`activitywatch.nix`); verify it works in VM; skip if unused
- [ ] **spotify-player** — skip; already using spicetify

### Round 4 — Hyprland config itself

- [ ] **Monitor config** — eDP-1: 3200x2000 @ 2.0 scale 120Hz; HDMI-A-2: 1920x1080 @ 60Hz mirror
- [ ] **Input settings** — repeat rate 50/300ms, numlock on, touchpad: natural scroll + tap-to-click, 3-finger workspace swipe
- [ ] **Keybinds** — migrate from Ubuntu `UserKeybinds.conf` + `Keybinds.conf`; key ones: Super+R=fuzzel, CTRL+ALT+L=lock, CTRL+ALT+P=wlogout
- [ ] **Window rules** — migrate floating rules, workspace assignments, opacity rules from `WindowRules.conf`
- [ ] **Decorations** — rounding 10px, blur size 6 passes 2, dim inactive 0.1, inactive opacity 0.9, active opacity 1.0
- [ ] **Environment variables** — migrate from `ENVariables.conf`: GDK_BACKEND, QT_QPA_PLATFORM, CLUTTER_BACKEND, XDG vars, HYPRCURSOR_THEME=Bibata-Modern-Ice size 24

---

## Program Swaps / Improvements

- [ ] **Remove `timeshift`** — redundant on NixOS; generations + `nh` handle rollback; ext4 not btrfs
- [ ] **Replace `conda` with `uv` + nix dev shells** — conda needs FHS paths that don't exist on NixOS
- [ ] **Replace SDDM with `greetd`** — SDDM pulls X.org even in Wayland mode; `greetd` + `tuigreet` is lighter and X-free (loses astronaut theme)
- [ ] **Remove `nil`, keep only `nixd`** — both are Nix LSP servers; `nixd` is more capable and actively developed
- [ ] **Consider replacing `oh-my-zsh`** — `starship` + direct plugins = faster startup (preference, not a bug)

---

## Neovim — Lua Config (`nvim-config` repo)

### Bugs
- [ ] **Typo `colorscheme.lua`** — `transparent_backgorund` → `transparent_background`; transparent mode silently broken
- [ ] **Remove `lua/vitor/plugins/obsidian.lua`** — no longer using Obsidian

### Deprecated
- [ ] **`neodev.nvim` → `lazydev.nvim`** — neodev archived July 2024; lazydev is the drop-in successor

### Mason / NixOS (critical)
- [ ] **`mason-lspconfig.lua` — set `ensure_installed = {}`** — LSP servers now from Nix
- [ ] **`mason-tool-installer.lua` — set `ensure_installed = {}`** — formatters/linters now from Nix

### Upgrade candidates
- [ ] **`blink.cmp` instead of `nvim-cmp`** — Rust-based, ~6x faster; now default in kickstart.nvim
- [ ] **`oil.nvim` instead of `nvim-tree`** — filesystem as editable buffer; more vim-native
- [ ] **`fzf-lua` instead of `telescope.nvim`** — now default in LazyVim; faster and lighter
- [ ] **Remove `comment.nvim`** — Neovim 0.10+ has native `gc`/`gcc` built-in
- [ ] **Configure `which-key`** — options table is empty; not doing anything

---

## Neovim — Nix Integration

- [ ] **Move nvim-config into this repo** — replace `fetchFromGitHub` + `update-nvim-auto.sh` with local `modules/user/nvim/config/`; provide plugins via `pkgs.vimPlugins` for full reproducibility
