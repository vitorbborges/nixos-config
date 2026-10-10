# Screenshot + annotation tools for Hyprland/Wayland (2026)

Research date: 2026-10-10. Scope: open-source screenshot capture/annotation tools usable on
this repo's desktop (NixOS, Hyprland/Wayland via UWSM). Current setup: `grim -g "$(slurp)"`
/ `grim` piped to `tee` + `wl-copy`, saving to `~/Media/Pictures/Screenshots`
(`modules/user/hyprland/keybinds.nix`, `modules/user/hyprland/scripts/screenshot-*.sh`).
Screen recording tools were out of scope.

Every nixpkgs attribute below was verified with `nix search nixpkgs` against the flake's
current nixos-unstable on the date above; versions are those eval results. "Wayland-native"
means capture works on wlroots/Hyprland without `xdg-desktop-portal` indirection.

## Summary

| Tool | Wayland-native? | Annotation editor | nixpkgs attr (version) | Maintenance |
|---|---|---|---|---|
| grim + slurp | Yes (wlr-screencopy) | No | `grim` (1.5.0) + `slurp` (1.5.0) | Stable, low activity ([grim 1.5.0, Jul 2025](https://gitlab.freedesktop.org/emersion/grim), [slurp 1.5.0, Dec 2023](https://github.com/emersion/slurp/releases/tag/v1.5.0)) |
| Satty | Yes (editor, wlroots-first) | Yes, full | `satty` (0.22.0) | Very active ([0.22.0, 2026-08-03](https://github.com/Satty-org/Satty/releases/tag/v0.22.0)) |
| Swappy | Yes (editor) | Yes, basic | `swappy` (1.8.0) | Active ([1.8.0, 2025-08-27](https://github.com/jtheoof/swappy/releases/tag/v1.8.0); commits Apr 2026) |
| hyprshot | Yes (grim wrapper) | No | `hyprshot` (1.3.0) | Stalled: last release [2024-06-01](https://github.com/Gustash/Hyprshot/releases), last push 2024-07-29 |
| grimblast | Yes (grim wrapper) | No (can pipe to editor) | `grimblast` (0.1-unstable-2026-08-21) | Active in [hyprwm/contrib](https://github.com/hyprwm/contrib) (commits May–Oct 2026) |
| Flameshot | No — portal-only on Wayland | Yes, full | `flameshot` (14.0.0) | Very active ([v14.0.0, 2026-06-19](https://github.com/flameshot-org/flameshot/releases/tag/v14.0.0); [v15.0.rc1, 2026-09-19](https://github.com/flameshot-org/flameshot/releases/tag/v15.0.rc1)) |
| Ksnip | No — portal-only on Hyprland | Yes, full | `ksnip` (1.10.1-unstable-2026-02-27) | Active repo, but no tagged release since [v1.10.1, 2023-03-15](https://github.com/ksnip/ksnip/releases/tag/v1.10.1) |
| Spectacle | No — requires KWin | Yes, full (+OCR in Plasma 6.6) | `kdePackages.spectacle` (6.7.5) | Active, KDE Gear |
| Gradia | Editor; capture via portal | Yes, full (+OCR 19 langs, backgrounds) | `gradia` (1.13.0) | Active ([1.14.0, 2026-09-30](https://apps.gnome.org/en/Gradia/)) |
| Xfce4-screenshooter | Partially (wlroots protocols) | No | `xfce4-screenshooter` (1.11.3) | Maintained ([1.11.3, 2025-11-05](https://www.mail-archive.com/xfce-announce@xfce.org/msg01186.html)) |
| GNOME Screenshot | No — dead | No | `gnome-screenshot` (41.0) | Archived upstream ([gitlab.gnome.org/Archive](https://gitlab.gnome.org/Archive/gnome-screenshot)); broken on GNOME 49+ |
| Shutter | No — portal-only, rudimentary | Yes, full | `shutter` (0.99.7) | Active bugfixes ([0.99.7, 2026-05-09](https://shutter-project.org/releases/0.99.7/)) |
| maim + slop | No — X11 only | No | `maim` (5.8.2) + `slop` (7.7) | Maintained, X11-only ([maim 5.8.2, 2026](https://github.com/naelstrof/maim/releases)) |
| HyprCapture | Yes — Hyprland compositor plugin | No | **not in nixpkgs** | New (May 2026), [wiki-listed](https://wiki.hypr.land/Useful-Utilities/Screenshots-and-Recording/) |
| Omasnap | Yes — Hyprland/Omarchy-native | Yes, full + OCR region | **not in nixpkgs** | New (2026), early-stage ([repo](https://github.com/devmobasa/omasnap)) |
| Wayscriber (was hyprmarker) | Yes — layer-shell overlay | Live overlay drawing (not a screenshot editor) | `wayscriber` (0.9.21) | Active ([v0.9.21, 2026-06-28](https://github.com/devmobasa/wayscriber)) |
| Shotman | Yes — wlroots capture + thumbnail | No | `shotman` (0.4.10) | Active on [sourcehut](https://sr.ht/~whynothugo/shotman/) |
| Wayshot | Yes — CLI only | No | `wayshot` (1.6.0) | Active, low-level library ([waycrate/wayshot](https://github.com/waycrate/wayshot)) |

## Group A — standalone capture + annotation apps

### Flameshot
- **What it is:** Qt app; region/window/fullscreen capture, full annotation editor (pencil,
  line, arrow, rectangle, circle, marker, text, pixelate/blur), undo/redo, pin (X11 only),
  delay (`-d`), clipboard copy, save dialog or save path, Imgur upload, D-Bus interface,
  external "open with" ([README](https://github.com/flameshot-org/flameshot#features)).
  No built-in OCR. Release Enter uploads to Imgur.
- **Wayland/Hyprland status:** no native wlroots capture. Since **v13** all Wayland capture goes
  through `xdg-desktop-portal`; **v14 (2026-06) made the portal the default on Linux** and made
  the legacy X11 path opt-in ([v14 release notes](https://github.com/flameshot-org/flameshot/releases/tag/v14.0.0),
  [nixpkgs PR #533614](https://github.com/NixOS/nixpkgs/pull/533614)). Upstream doc says it "works
  out of the box on Hyprland as long as `xdg-desktop-portal-hyprland` is installed and running"
  ([docs/UsageHyprlandSwayWlroots.md](https://github.com/flameshot-org/flameshot/blob/master/docs/UsageHyprlandSwayWlroots.md)).
  Reality check: an open issue (Feb 2026) shows non-interactive portal screenshots fail with
  `xdg-desktop-portal-hyprland` while interactive selection works; `xdg-desktop-portal-wlr` works
  around it ([flameshot#4543](https://github.com/flameshot-org/flameshot/issues/4543), closed
  as upstream — [xdg-desktop-portal-hyprland#381](https://github.com/hyprwm/xdg-desktop-portal-hyprland/issues/381)).
  On multi-monitor, v14 prompts for a monitor and **cannot** auto-capture the active monitor on
  Wayland; the nixpkgs PR suggests binding `flameshot screen -e` instead ([PR #533614](https://github.com/NixOS/nixpkgs/pull/533614)).
  Pin is unavailable on Wayland.
- **Dependencies:** Qt6 + KGuiAddons; on Wayland needs `xdg-desktop-portal` plus an
  implementation with the Screenshot interface (`xdg-desktop-portal-hyprland`; `grim`/`slurp`
  must be in PATH for the Hyprland portal to serve screenshots) and an Access interface provider
  (`xdg-desktop-portal-gtk`) ([upstream doc](https://github.com/flameshot-org/flameshot/blob/master/docs/UsageHyprlandSwayWlroots.md)).
- **nixpkgs:** `flameshot` 14.0.0 (home-manager module exists; `useX11LegacyScreenshot`,
  `captureActiveMonitor` options per [PR #533614](https://github.com/NixOS/nixpkgs/pull/533614)).
- **Maintenance:** very active; v13.3.0 Oct 2025, v14.0.0 Jun 2026, v15.0 RC Sep 2026.
- **Pros:** most complete editor; mature across X11/Windows/macOS; Imgur + D-Bus automation;
  strong release cadence.
- **Cons:** portal indirection on Hyprland with known rough edges; no active-monitor capture on
  Wayland; pin missing; heavier dependency stack than grim-based tools.

### Ksnip
- **What it is:** Qt capture + annotation (pen, marker, rect, ellipse, text, stickers, blur,
  crop), delayed capture, Imgur/script uploaders, single-instance CLI
  ([README](https://github.com/ksnip/ksnip#readme)).
- **Wayland/Hyprland status:** supports "Plasma Wayland, GNOME Wayland and xdg-desktop-portal
  Wayland" per README; on other compositors (Hyprland) it is portal-only, meaning the compositor
  shows its own selection UI and every capture requires portal confirmation. Region capture is
  **not** supported on Plasma Wayland; global hotkeys don't work on Wayland
  ([README Wayland table and notes](https://github.com/ksnip/ksnip#readme)). A 2025 text-tool
  segfault on Wayland was fixed by kImageAnnotator 0.7.x ([issue #1118](https://github.com/ksnip/ksnip/issues/1118)).
- **Dependencies:** Qt; xdg-desktop-portal backend for capture on wlroots.
- **nixpkgs:** `ksnip` (1.10.1-unstable-2026-02-27); may need "Force portal screenshot" in
  settings on Wayland.
- **Maintenance:** repo active (last push 2026-10-01) but no tagged release since 1.10.1
  (2023-03-15); 337 open issues.
- **Pros:** rich annotation + uploaders; cross-platform.
- **Cons:** no native wlroots capture; stale releases; Wayland clipboard quirks; global hotkeys
  unsupported.

### Swappy
- **What it is:** GTK3 Wayland-native snapshot **editor**: pen, text, arrow, rectangle, circle,
  blur, crop, undo/redo, save + copy; config file ([repo](https://github.com/jtheoof/swappy)).
  No OCR.
- **Wayland/Hyprland status:** works anywhere; reads an image from stdin (classic
  `grim -g "$(slurp)" - | swappy -f -`) or file/CLI. Clipboard persistence needs `wl-clipboard`
  installed (README notes GTK 3.24 limitation); Apr 2026 commit improved clipboard MIME types
  for apps expecting BMP etc. ([commit](https://github.com/jtheoof/swappy/commit/bfa7ef9943e1f5703d6747540152ad55764063b0)).
- **Dependencies:** GTK3, optional `wl-clipboard`.
- **nixpkgs:** `swappy` 1.8.0, no special config.
- **Maintenance:** active (1.7.x/1.8.0 Aug 2025; commits into 2026).
- **Pros:** dead simple, Wayland-native, tiny; feature set covers 90% of annotation needs.
- **Cons:** fewer tools/finish than Satty/Flameshot (no marker/highlight, no text effects, older
  GTK look); no capture of its own (must pipe).

### Satty
- **What it is:** Rust + GTK4/libadwaita annotation tool "inspired by Swappy and Flameshot":
  arrows/lines, rectangles, ellipses, text (multi-line, IME, outline/shadow effects), brush,
  marker, blur, highlight (freehand + block), crop, undo/redo, copy to clipboard, save via
  file/dialog, custom `--copy-command`, config TOML + CSS overrides, action triggers
  ([README](https://github.com/Satty-org/Satty), [0.22.0 notes](https://github.com/Satty-org/Satty/releases/tag/v0.22.0)).
  No OCR. Does not capture screens itself; designed to sit after grim/slurp.
- **Wayland/Hyprland status:** built for wlroots compositors (Sway, Hyprland, River, …);
  upstream ships the exact Hyprland bind in the README:
  `grim -g "$(slurp -o -r -c '##ff0000ff')" -t ppm - | satty --filename - --fullscreen --output-filename ~/Pictures/Screenshots/...`
  ([README](https://github.com/Satty-org/Satty)). The Hyprland wiki documents it as an "almost
  drop-in replacement for swappy" ([wiki, updated 2026-08-26](https://wiki.hypr.land/Useful-Utilities/Screenshots-and-Recording/)).
- **Dependencies:** GTK4/libadwaita, OpenGL; `wl-clipboard` for clipboard copy.
- **nixpkgs:** `satty` 0.22.0, no special config.
- **Maintenance:** very active (0.20.0 Jan 2026 → 0.22.0 Aug 2026; multiple maintainers).
- **Pros:** best-in-class Wayland annotation; smooth HW-accelerated rendering; fullscreen,
  post-shot crop, undo history; configurable.
- **Cons:** no built-in capture (pipeline required); no OCR; GTK4 styling not stylix-themed by
  default.

### Spectacle
- **What it is:** KDE capture app with annotation editor, delay, save/copy, export actions;
  Plasma 6.6 adds **OCR** ([KDE blog, 2025-11-15](https://blogs.kde.org/2025/11/15/this-week-in-plasma-ocr-in-spectacle-and-many-ui-improvements/)).
- **Wayland/Hyprland status:** on Wayland, Spectacle **requires KWin** — its own error message
  says "On Wayland, Spectacle requires KDE Plasma's KWin compositor" ([Fedora discussion](https://discussion.fedoraproject.org/t/cant-take-screenshots-kde-wayland/127897),
  [KDE bug 504023](https://bugs.kde.org/show_bug.cgi?id=504023)). Not usable on Hyprland.
- **Dependencies:** KDE Frameworks; KWin on Wayland.
- **nixpkgs:** `kdePackages.spectacle` 6.7.5 (pull in KDE stack on a non-KDE system).
- **Maintenance:** active KDE Gear.
- **Pros (on KDE):** polished, OCR, annotations, Plasma integration.
- **Cons:** KWin-only on Wayland → irrelevant for Hyprland; heavy deps if only used as a tool.

### Xfce4-screenshooter
- **What it is:** Xfce capture utility: region/window/fullscreen, delay, save/copy/open-with,
  custom actions. **No annotation editor.**
- **Wayland/Hyprland status:** preliminary Wayland support since 1.10.6 (2024-05), wlroots-based
  compositors only; **1.11.3 (2025-11-05) added Wayland region selection** and fullscreen capture
  via `ext_image_capture_source`/`copy_capture` ([NEWS](https://gitlab.xfce.org/apps/xfce4-screenshooter/-/raw/master/NEWS),
  [announce](https://www.mail-archive.com/xfce-announce@xfce.org/msg01186.html)). Xfce itself
  calls Wayland support experimental. No portal path.
- **Dependencies:** GTK3/Xfce libs.
- **nixpkgs:** `xfce4-screenshooter` 1.11.3.
- **Maintenance:** maintained by Xfce (regular releases).
- **Pros:** simple, lightweight; legit wlroots path after 1.11.3.
- **Cons:** no annotations; niche on Hyprland; less tested than grim.

### GNOME Screenshot
- **What it is:** legacy GNOME capture tool; no annotation.
- **Status:** removed from GNOME core after the built-in screenshot UI landed; repository is
  **archived** ([gitlab.gnome.org/Archive/gnome-screenshot](https://gitlab.gnome.org/Archive/gnome-screenshot));
  GNOME 49 (2025) removed its private API access, breaking it
  ([gnome-shell MR !3760](https://gitlab.gnome.org/GNOME/gnome-shell/-/merge_requests/3760),
  [Arch forum](https://bbs.archlinux.org/viewtopic.php?id=308445)). nixpkgs still carries
  `gnome-screenshot` 41.0 (last release 2022).
- **Verdict:** do not use.

### Shutter
- **What it is:** Perl/GTK3 capture + full annotation editor, profiles, upload plugins
  (Imgur plugin removed), timer, save/copy.
- **Wayland/Hyprland status:** "rudimentary" portal support since 0.99.1: Shutter asks the
  compositor to run its implementation-defined picker; Shutter cannot control the selection UI
  ([CHANGES](https://github.com/shutter-project/shutter/blob/master/CHANGES),
  [dependencies page](https://shutter-project.org/downloads/dependencies/)). On Hyprland this
  means slurp's UI driven by the portal, then editing in Shutter — workable but awkward. X11 is
  the first-class target.
- **Dependencies:** GTK3, Perl, `xdg-desktop-portal` + compositor backend on Wayland.
- **nixpkgs:** `shutter` 0.99.7.
- **Maintenance:** alive — bugfix releases (0.99.6 Mar 2025, 0.99.7 May 2026), small team.
- **Pros:** powerful editor; still receiving fixes.
- **Cons:** portal-only capture; GTK3/X11-era design; heavy Perl deps.

### Maim + Slop
- **What it is:** classic X11 capture (`maim`) + selection (`slop`) combo.
- **Status:** X11-only — useless under Hyprland/Wayland (README and package deps are X11;
  maim 5.8.2 built June 2026, [releases](https://github.com/naelstrof/maim/releases)).
  Actively maintained as an X11 tool.
- **nixpkgs:** `maim` 5.8.2, `slop` 7.7.
- **Verdict:** irrelevant on this setup.

### Newer annotation tools (2024–2026)
- **Gradia** — Python/GTK4/libadwaita; ten annotation modes, censor tool, text/arrows,
  backgrounds/shadows, Imgur upload, **OCR (19 languages)**, code-snippet rendering
  ([apps.gnome.org](https://apps.gnome.org/en/Gradia/), [releases](https://github.com/AlexanderVanhee/Gradia/releases)).
  Capture on Wayland goes through the Screenshot portal; GNOME-styled but runs on Hyprland as an
  editor. nixpkgs `gradia` 1.13.0 (upstream 1.14.0, 2026-09-30). Good for "beautified"
  screenshots; less of a Hyprland-native capture flow.
- **Omasnap** — new Hyprland/Omarchy-native capture+annotation overlay: region/window/full
  capture via `grim`/`hyprctl`, movable vector annotation layers, numbered markers, arrows,
  text, backdrops, **OCR region via tesseract**, clipboard via `wl-copy`
  ([repo](https://github.com/devmobasa/omasnap)). Early-stage, **not in nixpkgs**; most
  interesting newcomer if you want Satty-style editing with capture built in.
- **Wayscriber (formerly hyprmarker)** — Rust layer-shell **live annotation overlay**
  (ZoomIt-like): draw over apps in real time, board/whiteboard modes, zoom, presenter mode,
  capture shortcuts via grim/slurp; "save annotations to image" is still on the roadmap, so it
  complements rather than replaces a screenshot editor ([repo](https://github.com/devmobasa/wayscriber),
  nixpkgs `wayscriber` 0.9.21).
- **HyprCapture** — Hyprland-only (compositor plugin via `hyprpm` + Qt helper): frozen-desktop
  overlay, region/window/full capture, clipboard + thumbnail, recording
  ([repo](https://github.com/gfhdhytghd/HyprCapture), listed on the
  [Hyprland wiki](https://wiki.hypr.land/Useful-Utilities/Screenshots-and-Recording/)).
  **No annotation editor.** Not in nixpkgs; plugin ABI must match the Hyprland version.
- **Kshot** — KDE-only reimplementation skipping portals via `org.kde.KWin.ScreenShot2`; not
  relevant to Hyprland ([repo](https://github.com/jibsta210/kshot)).

## Group B — Hyprland/wlroots-native workflows

### grim + slurp (current setup)
- **What it is:** `grim` captures (output/region, stdin/stdout, PNG/PPM), `slurp` selects regions
  or outputs. No annotation, no delay, no clipboard (pipe to `wl-copy`).
- **Status:** stable and boring in a good way. grim 1.5.0 (Jul 2025) now lives at
  [gitlab.freedesktop.org/emersion/grim](https://gitlab.freedesktop.org/emersion/grim); slurp
  1.5.0 (Dec 2023) at [github.com/emersion/slurp](https://github.com/emersion/slurp/releases/tag/v1.5.0).
  Hyprland implements wlr-screencopy, so both work natively.
- **nixpkgs:** `grim` 1.5.0, `slurp` 1.5.0. Already what this repo uses
  (`modules/user/hyprland/keybinds.nix`).
- **Pros:** zero-friction, scriptable, tiny; exactly what Hyprland users keep falling back to.
- **Cons:** no UI/annotation; "freeze screen while selecting" needs an extra tool
  (`wayfreeze` 0.2.1 or `still` 0.0.10 in nixpkgs, or grimblast's `--freeze` via hyprpicker).

### hyprshot
- **What it is:** bash wrapper over grim/slurp/hyprctl, modes `region|window|output`,
  clipboard-only or save-to-dir, notifications, `--freeze` (needs hyprpicker), `--raw` stdout
  ([README](https://github.com/Gustash/Hyprshot#readme)).
- **Status:** functionally frozen. Latest release **1.3.0, 2024-06-01**; last commit
  **2024-07-29** ([repo metadata](https://github.com/Gustash/Hyprshot)); 79 open issues. It still
  works (plain grim calls), and distros/community scripts use it widely (e.g. ML4W's switch to
  hyprshot+satty, [ML4W#1800](https://github.com/mylinuxforwork/dotfiles/issues/1800); forum
  answers recommend `-z` freeze, [Hyprland forum](https://forum.hypr.land/t/cannot-execute-grimblast-via-bind/659)).
- **nixpkgs:** `hyprshot` 1.3.0; deps jq/grim/slurp/wl-clipboard/libnotify, optional hyprpicker.
- **Pros:** nice CLI ergonomics; per-window capture; still works.
- **Cons:** unmaintained since mid-2024; no annotation; no official Hyprland endorsement.

### grimblast
- **What it is:** hyprwm/contrib's grim wrapper (grimshot port): `area|active|output|screen`
  targets, `copy|save|edit` actions, `--freeze` (hyprpicker), per-window selection across
  workspaces, and `GRIMBLAST_EDITOR` to pipe into an editor, e.g.
  `GRIMBLAST_EDITOR="satty --filename" grimblast --freeze edit area`
  ([script source](https://github.com/hyprwm/contrib/blob/main/grimblast/grimblast),
  [forum tip](https://forum.hypr.land/t/cannot-execute-grimblast-via-bind/659)).
- **Status: NOT deprecated.** It is the opposite of the rumor: commits landed **May–Oct 2026**,
  including Hyprland 0.55 Lua-config support (Aug 2026) and frozen-cursor fixes (Oct 2026), all
  merged by Hyprland maintainer fufexan ([commit log](https://github.com/hyprwm/contrib/commits/main/grimblast)).
  nixpkgs tracks it at `grimblast` 0.1-unstable-2026-08-21. Note the current Hyprland wiki page
  no longer lists grimblast (it features grim+swappy, Satty, Flameshot, HyprCapture), but the
  project itself is alive and maintained.
- **nixpkgs:** `grimblast` (or via the `hyprland-contrib` flake input, per
  [contrib README](https://github.com/hyprwm/contrib#readme)).
- **Pros:** best out-of-the-box Hyprland semantics (window rects from hyprctl, freeze, editor
  hook); actively maintained inside hyprwm.
- **Cons:** no annotation itself (needs editor hook); shell script with many deps
  (grim, slurp, hyprctl, hyprpicker, wl-copy, jq, notify-send).

### grim + slurp piped into Satty or Swappy
- The standard 2025/2026 Hyprland answer. Hyprland wiki (updated 2026-08-26) documents exactly
  this for swappy and satty, and the r/hyprland 2025–2026 threads repeat it
  ([wiki](https://wiki.hypr.land/Useful-Utilities/Screenshots-and-Recording/),
  [r/hyprland Oct 2025](https://www.reddit.com/r/hyprland/comments/1l9r35d/can_someone_suggest_me_a_screenshot_tool_with/)).
- PPM beats PNG for the pipe (`-t ppm`), per Satty README.

### Other nixpkgs-packaged, Hyprland-viable bits
- `shotman` 0.4.10 — wlroots-native capture GUI: captures, saves, shows a floating thumbnail
  (copy/delete/dismiss); `--capture window` is sway-only; requires wlr_screencopy + layer-shell
  ([site](https://shotman.whynothugo.nl/), active on [sourcehut](https://sr.ht/~whynothugo/shotman/)).
  No annotation.
- `wayshot` 1.6.0 — Rust CLI/library for wlroots screencopy; building block, no UI/annotation
  ([repo](https://github.com/waycrate/wayshot)).
- `wayfreeze` 0.2.1 / `still` 0.0.10 — freeze-screen helpers for selection workflows.
- `grim-hyprland` — grim fork adding Hyprland's window-capture protocol, for clean single-window
  grabs without occlusion ([listed in awesome-hyprland](https://github.com/hyprland-community/awesome-hyprland)).
- `sway-contrib.grimshot` 1.11 — the sway ancestor of grimblast; use grimblast instead on
  Hyprland.

## What Hyprland users actually use in 2025/2026

- **The Hyprland wiki** (the project's own "commonly used tools" page, updated 2026-08-26)
  lists: grim + swappy, **Satty** ("almost drop-in replacement for swappy"), Flameshot (with a
  portal caveat: "if it cannot capture the screen... use grim with swappy instead"), plus the
  new HyprCapture (<https://wiki.hypr.land/Useful-Utilities/Screenshots-and-Recording/>).
- **r/hyprland / forums:** recurring recommendation is hyprshot or grim+slurp for capture and
  **Satty** for annotation ("Satty... best tool as of now", "I've been using hyprshot and
  haven't had any issues") ([thread, Oct 2025](https://www.reddit.com/r/hyprland/comments/1l9r35d/can_someone_suggest_me_a_screenshot_tool_with/),
  [Hyprland forum, Aug 2025](https://forum.hypr.land/t/cannot-execute-grimblast-via-bind/659)).
- **Distro/DE defaults in 2025–2026:** ML4W dotfiles replaced grimblast with **hyprshot + Satty**
  as the default flow ([ML4W #1800](https://github.com/mylinuxforwork/dotfiles/issues/1800));
  Omarchy (DHH's Hyprland distro) ships **Satty** in its base screenshot stack
  ([satty man page note](https://linuxcommandlibrary.com/man/satty)).
- **Flameshot on Hyprland:** used, but usually with the caveat that it needs portal plumbing and
  has quirks; guides call it "experimental on Wayland"
  ([daily.dev guide](https://daily.dev/posts/taking-screenshots-in-hyprland-j0uyudlwu),
  [flameshot#4543](https://github.com/flameshot-org/flameshot/issues/4543)).

**Is Flameshot's editor still the differentiator?** Partially. It remains the most mature
all-in-one editor (annotation + pixelate + Imgur + D-Bus + cross-platform), and v14/v15 keep it
alive. But on Wayland its differentiator has narrowed: Satty matches the core toolset
(arrows/text/blur/highlight/marker/crop/undo) with better Wayland behavior, and Gradia adds OCR
and "beautify for sharing" workflows Flameshot lacks. No wlroots-native tool matches Flameshot's
Imgur/DBus automation out of the box, but that's scriptable and rarely worth the portal friction.

## Verdict

1. **Best fit for this machine: Satty + existing grim/slurp.** It drops into the current scripts
   with one pipe (`... | satty --filename -`), works natively on Hyprland, is the most actively
   developed annotation tool in this survey, and needs one line in
   `modules/user/hyprland/keybinds.nix` and `home.packages`. Add `satty` (0.22.0).
2. **If you want all-in-one capture+editor like Flameshot:** Flameshot 14.0.0 is viable on
   Hyprland via `xdg-desktop-portal-hyprland` + `grim`/`slurp`, but expect the documented
   portal quirks (non-interactive capture failure mode, per-monitor prompt, no pin, no
   active-monitor auto-capture). It's the tool with the steepest Wayland integration risk.
3. **Do not bother with:** hyprshot (unmaintained since mid-2024), gnome-screenshot (archived),
   Spectacle (requires KWin), ksnip/Shutter (portal-only on Hyprland), maim/slop (X11).
4. **User's belief checked:** grimblast is **not** deprecated — it got commits as recently as
   Oct 5, 2026 inside hyprwm/contrib and is packaged at a 2026-08-21 revision. It's the
   strongest choice if you want capture semantics (freeze, window rects) with an editor hook:
   `GRIMBLAST_EDITOR="satty --filename" grimblast --freeze edit area`.
5. **Watch list (not in nixpkgs yet):** Omasnap (Hyprland-native capture+annotation with OCR),
   HyprCapture (wiki-listed Hyprland plugin, no annotations), Wayscriber (live drawing overlay).

Suggested minimal change consistent with the repo: keep `hl-screenshot-area`/`hl-screenshot-full`
as-is, add a third bind that pipes grim+slurp into Satty and saves to
`~/Media/Pictures/Screenshots` (same folder), copying to clipboard on Ctrl+C inside Satty.
