# Baremetal Migration — ASUS Vivobook (Intel + RTX 4070)

This is the complete, sequential runbook. Work top to bottom. Do not skip steps.

---

## Step 0 — Commit and Push (do this on Ubuntu first)

```bash
cd ~/nixos-config
git add -A
git commit -m "chore: finalise config before baremetal migration"
git push
git log --oneline -3   # confirm the commit is there
```

---

## Part 1 — Install NixOS

**Use:** NixOS minimal ISO (no DE). Boot from USB.

During Calamares:
- **Partitioning** — note whether the ESP mounts at `/boot` or `/boot/efi` before confirming
- **Username** — must be `vitor` (hardcoded in `flake.nix`)
- **Desktop** — select **None / No desktop**
- **Password** — set a temporary password; you'll change it after first boot

After the installer reboots you land in a TTY. Log in as `vitor`.

---

## Part 2 — First Boot Setup (TTY)

Run these commands in order. If any step fails, read the error, fix it, then re-run.

### 2.1 — Connect to WiFi

```bash
nmtui
```

Navigate: Activate a connection → select your network → enter password.

### 2.2 — Clone the config

```bash
git clone https://github.com/vitorbborges/nixos-config ~/nixos-config
```

### 2.3 — Generate and copy hardware config

```bash
nixos-generate-config
cp /etc/nixos/hardware-configuration.nix ~/nixos-config/hardware-configuration.nix
```

### 2.4 — Stage the hardware config (CRITICAL — flake requires git-tracked files)

```bash
cd ~/nixos-config
git add hardware-configuration.nix
```

### 2.5 — Check ESP mount point

The default `boot.nix` expects the EFI partition at `/boot/efi`.
If Calamares mounted it at `/boot` instead:

```bash
sed -i 's|/boot/efi|/boot|g' ~/nixos-config/modules/system/boot.nix
git add modules/system/boot.nix
```

If it's at `/boot/efi`, do nothing.

### 2.6 — Check NVIDIA Bus IDs

```bash
lspci | grep -E 'VGA|3D'
```

Expected output (any order):
```
00:02.0 VGA compatible controller: Intel ...
01:00.0 3D controller: NVIDIA ... RTX 4070 ...
```

The config has `intelBusId = "PCI:0:2:0"` and `nvidiaBusId = "PCI:1:0:0"`.
If your output shows different addresses, edit before rebuilding:

```bash
nano ~/nixos-config/modules/system/nvidia/nvidia.nix
# Change intelBusId / nvidiaBusId to match lspci output (format: PCI:bus:device:function)
git add modules/system/nvidia/nvidia.nix
```

### 2.7 — Rebuild

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#vivobook
```

This takes several minutes on first run (downloads all packages).
Watch for errors. If it fails, fix the error, then re-run.

### 2.8 — Set passwords

```bash
passwd vitor        # your real user password
sudo passwd root    # lock root or set a root password
# To lock root login entirely: sudo passwd -l root
```

### 2.9 — Reboot

```bash
reboot
```

---

## Part 3 — First Login

You will see **tuigreet** (a terminal-style login screen — not a graphical DM).

- Username: `vitor`
- Password: whatever you set in step 2.8

After login, **Hyprland starts automatically** via UWSM.

### What autostart on first login:
- `waybar` — top bar (systemd user service)
- `hyprpaper` — wallpaper daemon (systemd user service)
- `hypridle` — idle/lock timer (systemd user service)
- `swaync` — notification center (systemd user service)
- `hyprpolkitagent` — polkit agent (exec-once in Hyprland config)

All of these are declared as home-manager services and start automatically.
You do **not** need to launch them manually.

### Default wallpaper

The default wallpaper is the one baked into the build via `stylix.image`.
To set a new wallpaper:

```bash
mkdir -p ~/Pictures/Wallpapers
# Copy an image file into ~/Pictures/Wallpapers/, then:
wallpaper-switch ~/Pictures/Wallpapers/your-image.jpg
```

This sets the wallpaper immediately and triggers a background rebuild to propagate
the colorscheme to all apps (~1–2 min). A notification appears when done.

---

## Part 4 — Verify Hardware

Run these checks and fix anything that's wrong before calling the migration complete.

| Check | Command / Action | Expected |
|-------|-----------------|----------|
| NVIDIA GPU | `nvidia-smi` | Shows RTX 4070 |
| NVIDIA offload | `glxinfo \| grep renderer` | NVIDIA renderer |
| Audio Fn keys | Press mute / vol up / vol down | OSD notifications appear |
| Audio mixer | `$mod+S` | wiremix TUI opens, shows devices |
| Bluetooth | `$mod+B` | bluetui TUI opens |
| Bluetooth pairing | Pair a device in bluetui | Works |
| WiFi | `$mod+W` | wifitui TUI opens |
| Touchpad | Scroll naturally, tap to click | Works |
| HiDPI | Check text/UI size | Everything looks right at 2× scale |
| Hyprlock | `Ctrl+Alt+L` | Lock screen appears, password accepted |
| Screenshots | `Print` (area), `Shift+Print` (full) | Saved to `~/Pictures/Screenshots/` |
| Keyboard layout | `$mod+Space` | Toggles us ↔ br |
| Brightness keys | Fn+F6/F7 | OSD shows brightness % |
| Keyboard backlight | Fn+F3/F4 | Keyboard brightness changes |
| Syncthing | Open `127.0.0.1:8384` in browser | Web UI loads |
| ActivityWatch | Open `127.0.0.1:5600` in browser | Dashboard loads |

---

## Part 5 — Home Directory Setup

Create the target directory structure (run in Hyprland terminal, `$mod+Return`):

```bash
mkdir -p ~/Education/{Laurea\ Magistrale,Undergraduate}
mkdir -p ~/Investments
mkdir -p ~/Media/{Music,Videos/Caiaque,Videos/Screencasts,Books}
mkdir -p ~/Pictures/{Screenshots,Wallpapers}
mkdir -p ~/Notes
mkdir -p ~/Projects
mkdir -p ~/Templates
```

Then migrate content from Ubuntu (via Syncthing, USB, or `rsync` over SSH):

| Source (Ubuntu) | Destination (NixOS) | Notes |
|-----------------|---------------------|-------|
| `~/Documents/` | `~/Documents/` | Rename subdirs (see below) |
| `~/Desktop/Education/` | `~/Education/` | |
| `~/Desktop/Investments/` | `~/Investments/` | |
| `~/Music/` | `~/Media/Music/` | |
| `~/Videos/` | `~/Media/Videos/` | |
| `~/Obsidian/` | `~/Notes/` | Update vault path in Obsidian after |
| `~/Pictures/` | `~/Pictures/` | Merge `wallpapers/` → `Wallpapers/` |
| `~/Desktop/Projects/` | `~/Projects/` | |
| `~/pipeline/` | `~/Projects/pipeline/` | |

Rename subdirs under `~/Documents/`:
- `"Academic Documents"` → `Academic/`
- `"Brazilian Documents"` → `Brazilian/`
- `"Italian Documents"` → `Italian/`
- `"Miscellaneous Certificates"` → `Certificates/`
- `"backup codes"` → `Backup Codes/`

**Drop on NixOS** (do not migrate):
- `~/Desktop/` — no concept in Hyprland
- `~/R/` — packages declared in nix
- `~/miniconda3/`, `~/micromamba/` — replaced by nix dev shells
- `~/go/` — keep at `~/go/` (Go tooling convention)
- `~/kafka_2.13-4.1.0/` — use a devshell; delete
- `~/Desktop/Programming/` — scratch work, migrate anything useful to `~/Projects/`

---

## Part 6 — Post-Migration Cleanup

These can wait until after you're settled but should be done before daily use:

1. **Obsidian vault path** — point Obsidian to `~/Notes/` after migrating `~/Obsidian/`
2. **Syncthing** — re-pair devices, update folder paths to new structure
3. **ActivityWatch** — verify `127.0.0.1:5600` is tracking correctly
4. **Minecraft** — open Prismlauncher, add JVM arg `-Dsun.java2d.uiScale=2` for HiDPI
5. **MIME types** — `xdg.nix` has broken MIME associations (known TODO); fix or ignore
6. **Passwordless sudo** — `users.nix` allows passwordless `nixos-rebuild` for `wallpaper-switch`.
   Review if acceptable on baremetal. To remove: delete `security.sudo.extraRules` block in
   `modules/system/users.nix` and rebuild.

---

## Recovery Reference

You are never in a situation that requires reinstalling.

| Problem | Fix |
|---------|-----|
| Hyprland won't start | `Ctrl+Alt+F2` → TTY → fix config → `sudo nixos-rebuild switch --flake ~/nixos-config#vivobook` |
| Bad rebuild broke the system | Reboot → at systemd-boot menu, select a previous generation |
| NVIDIA display issues | TTY → fix `nvidia.nix` → rebuild |
| Can't connect to WiFi | Plug in ethernet; `nmtui` works in TTY too |
| Hyprlock rejects password | Check `security.pam.services.hyprlock = {}` is in `users.nix` (it is) |
| Forgot to `git add` a file | `cd ~/nixos-config && git add <file> && sudo nixos-rebuild switch ...` |
| True worst case | Boot NixOS live USB → mount partition → `nixos-enter` → rebuild |
