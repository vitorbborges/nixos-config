# NixOS Config TODO

Priority order: Bugs → Redundant packages → Structural → Missing components → Program swaps

---

## Redundant Packages

`programs.X.enable = true` already installs the package — these `home.packages` entries are pure duplication:

- [x] `zsh.nix` — remove `eza`, `bat`, `fzf` (`programs.eza` + `programs.fzf` handle them)
- [ ] `git.nix` — remove `git`, `lazygit` (`programs.git` + `programs.lazygit` handle them)
- [ ] `ssh.nix` — remove `openssh` (`programs.ssh.enable` handles it)
- [ ] `kitty.nix` — remove `pkgs.kitty` (`programs.kitty.enable` handles it)
- [ ] `nvim.nix` — remove `git`, `curl`, `wget` (system-wide or covered elsewhere)

---

## "Change One Place" Violations

- [ ] **`username` hardcoded in 4+ places** — add `let username = "vitorbborges";` in `flake.nix`, pass via `specialArgs`
- [ ] **Keyboard layout defined 3 times** — `configuration.nix`, `system/hyprland/hyprland.nix`, `user/hyprland/hyprland.nix`. Single variable via `specialArgs`.
- [ ] **`allowUnfree = true` in 2 remaining places** — `configuration.nix:59` (only `flake.nix` needed)
- [ ] **SDDM resolution hardcoded to 1920x1080** — monitor is 3200x2000; fix in `system/hyprland/hyprland.nix`
- [ ] **`font`/`fontPkg` specialArgs coupling** — stylix manages fonts globally; only `zathura.nix` and `system/fonts.nix` need these

---

## Structural / Architecture Issues

- [ ] **`system/fonts.nix` sets JetBrains Mono as serif/sans-serif** — wrong; contradicts stylix which correctly uses DejaVu
- [ ] **Duplicate font installation** — `modules/user/fonts.nix` and `modules/system/fonts.nix` both install same nerd font
- [x] **`zsh-nix-shell` fetched from GitHub** — use `pkgs.zsh-nix-shell` with `file = "share/zsh-nix-shell/nix-shell.plugin.zsh"`
- [x] **`fzf-tab` fetched from GitHub** — use `pkgs.zsh-fzf-tab`
- [ ] **`spicetify-nix` missing `inputs.nixpkgs.follows`** — brings own nixpkgs copy, inflating closure
- [ ] **`environment.variables` EDITOR/VISUAL in `configuration.nix`** — neovim is in HM profile; remove system vars, keep `programs.neovim.defaultEditor = true`

---

## Security

- [ ] **Syncthing bound to all interfaces** — change `guiAddress` from `0.0.0.0:8384` to `127.0.0.1:8384`

---

## Missing Components

- [ ] **Audio** — `services.pipewire` not configured; sound won't work
- [ ] **Wallpaper daemon** — no `swww`; screen blank on login
- [ ] **Status bar** — `waybar` referenced in stylix targets but not configured; `ags` absent entirely
- [ ] **Bluetooth** — `hardware.bluetooth.enable` missing
- [ ] **Clipboard manager** — `wl-clipboard` / `cliphist` not configured
- [ ] **`hypridle` / `hyprlock`** — present in Ubuntu, absent here
- [ ] **Notification daemon** — `swaync` or `dunst` missing

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

## Neovim — Nix Integration

- [ ] **Move nvim-config into this repo** — replace `fetchFromGitHub` + `update-nvim-auto.sh` with local `modules/user/nvim/config/`; provide plugins via `pkgs.vimPlugins` for full reproducibility
