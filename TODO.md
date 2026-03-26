# NixOS Config TODO

Priority order: Bugs → Redundant packages → Structural → Missing components → Program swaps

---

## Bugs (broken right now)

- [x] **Typo in zsh alias** — fixed `update-nvi-auto.sh` → `update-nvim-auto.sh`
- [x] **VM keybindings in Hyprland** — removed `env LIBGL_ALWAYS_SOFTWARE=1` from terminal binds
- [x] **NVIDIA Wayland env vars commented out** — uncommented `LIBVA_DRIVER_NAME`, `__GLX_VENDOR_LIBRARY_NAME`, `NVD_BACKEND`

---

## Redundant Packages

`programs.X.enable = true` already installs the package — these `home.packages` entries are pure duplication:

- [ ] `zsh.nix` — remove `eza`, `bat`, `fzf` from `home.packages` (`programs.eza` + `programs.fzf` handle them)
- [ ] `git.nix` — remove `git`, `lazygit` from `home.packages` (`programs.git` + `programs.lazygit` handle them)
- [ ] `ssh.nix` — remove `openssh` from `home.packages` (`programs.ssh.enable` handles it)
- [ ] `kitty.nix` — remove `pkgs.kitty` from `home.packages` (`programs.kitty.enable` handles it)
- [ ] `nvim.nix` — remove `git`, `curl`, `wget` from `home.packages` (already system-wide or covered elsewhere)

---

## "Change One Place" Violations

- [ ] **`username` hardcoded in 4+ places** — `vitorbborges` appears in `configuration.nix`, `home.nix`, `flake.nix`, and `autoUpgrade.flake` path. Add `let username = "vitorbborges";` in `flake.nix` and pass via `specialArgs`.
- [ ] **Keyboard layout defined 3 times** — `configuration.nix:44`, `system/hyprland/hyprland.nix:58`, `user/hyprland/hyprland.nix:28`. Single variable via `specialArgs`.
- [ ] **`allowUnfree = true` in 3 places** — `flake.nix:41`, `configuration.nix:59`, `home.nix:5`. Only `flake.nix` is needed since `pkgs` is shared.
- [ ] **SDDM resolution hardcoded to 1920x1080** — `system/hyprland/hyprland.nix:27-30` but monitor is 3200x2000. Fix or derive from a single variable.
- [ ] **`font`/`fontPkg` specialArgs coupling** — stylix already manages fonts globally; only `zathura.nix` and `system/fonts.nix` actually need these. Consider removing from specialArgs and referencing stylix config directly.

---

## Structural / Architecture Issues

- [ ] **`system/fonts.nix` uses JetBrains Mono as serif and sans-serif** — wrong; JetBrains Mono is monospace only. Stylix already sets DejaVu for serif/sans. This module contradicts stylix.
- [ ] **Duplicate font installation** — `modules/user/fonts.nix` and `modules/system/fonts.nix` both install the same nerd font package. Remove one.
- [ ] **`zsh-nix-shell` fetched from GitHub** — available in nixpkgs as `pkgs.zsh-nix-shell`; remove `fetchFromGitHub`, use `file = "share/zsh-nix-shell/nix-shell.plugin.zsh"`
- [ ] **`fzf-tab` fetched from GitHub** — available in nixpkgs as `pkgs.zsh-fzf-tab`; remove `fetchFromGitHub`
- [ ] **`spicetify-nix` missing `inputs.nixpkgs.follows`** — brings its own nixpkgs copy, inflating closure size. Add `inputs.nixpkgs.follows = "nixpkgs";`
- [ ] **`environment.variables` EDITOR/VISUAL in `configuration.nix`** — neovim is in the home-manager profile, not system. Remove system-level vars; `programs.neovim.defaultEditor = true` in home-manager is correct.
- [ ] **Home Manager standalone vs NixOS module** — currently requires two separate commands (`nixos-rebuild` + `home-manager switch`). Integrating via `home-manager.nixosModules.home-manager` allows a single `nixos-rebuild switch`. Consider migrating.

---

## Security

- [ ] **Syncthing bound to all interfaces** — `syncthing.nix:5` `guiAddress = "0.0.0.0:8384"` exposes the UI on every network interface. Change to `127.0.0.1:8384`.

---

## Missing Components (present in Ubuntu, absent in NixOS config)

- [ ] **Audio** — no `services.pipewire` configuration; sound won't work
- [ ] **Wallpaper daemon** — no `swww` or equivalent; screen will be blank on login
- [ ] **Status bar** — `waybar` is referenced in stylix targets but not configured; `ags` is absent entirely
- [ ] **Bluetooth** — `hardware.bluetooth.enable` missing
- [ ] **Clipboard manager** — `wl-clipboard` / `cliphist` not configured
- [ ] **`hypridle` / `hyprlock`** — present in Ubuntu setup, absent here
- [ ] **Notification daemon** — `swaync` or `dunst` missing

---

## Program Swaps / Improvements

- [ ] **Remove `timeshift`** — redundant on NixOS; generations + `nh` already handle rollback. Only useful for btrfs snapshots, but you're on ext4.
- [ ] **Replace `conda` with `uv` + nix dev shells** — conda relies on FHS paths that don't exist on NixOS (`/usr/lib`, `/usr/bin`). You already have `uv`; use `uv` + per-project `shell.nix` / `flake.nix` instead.
- [ ] **Replace `greetd` for SDDM** — SDDM pulls in X.org even in Wayland mode. `greetd` + `tuigreet` (or `regreet`) is lighter, X-free, and the standard for Hyprland. (Note: lose the astronaut theme)
- [ ] **Remove `nil`, keep only `nixd`** — both are Nix LSP servers; `nixd` is more actively developed and flake-aware. `nil` is redundant.
- [ ] **Consider replacing `oh-my-zsh`** — only used for `fox` theme + 5 plugins. `starship` + direct plugin declarations gives the same result with faster startup. (preference, not a bug)

---

## Already Fixed

- [x] **XDG dirs inactive** — removed dead `mkEnableOption` guard in `xdg.nix`; config now always applies
- [x] **VirtualBox config removed** — purged from `hardware-configuration.nix` and `configuration.nix`; replaced with correct UEFI/systemd-boot and real hardware profile
- [x] **PRIME bus IDs documented** — `nvidia.nix` updated with confirmed bus IDs and battery optimization comments
- [x] **Home Manager integrated as NixOS module** — `flake.nix` updated; single `nixos-rebuild switch` now applies system + user config together
- [x] **`allowUnfree` conflict** — removed from `home.nix` and `vscodium.nix`; inherited from system pkgs via `useGlobalPkgs = true`
