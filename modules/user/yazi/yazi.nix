{ pkgs, ... }:

let
  openWith = pkgs.writeShellScript "yazi-open-with"
    (builtins.readFile ./scripts/open-with.sh);

  nvimOpen = pkgs.writeShellScript "yazi-nvim-open" ''
    set -euo pipefail

    [ "$#" -gt 0 ] || exit 2
    target=$1

    if [ -d "$target" ]; then
      cd -- "$target"
      exec nvim .
    fi

    # Start nvim in the file's directory so its tree/root follows the file.
    cd -- "$(dirname -- "$target")"
    exec nvim -- "$@"
  '';

  # yatline 0.5.0 still calls the removed `File:icon()` API, which makes yazi
  # pop a "Deprecated API" toast on every hover. Patch it to the current
  # `th.icon:match(file)` API instead of losing the extension icon.
  yatline = pkgs.yaziPlugins.yatline.overrideAttrs (o: {
    postPatch = (o.postPatch or "") + ''
      substituteInPlace main.lua \
        --replace-fail 'local icon = hovered:icon().text' \
                       'local _ic = th.icon:match(hovered); local icon = _ic and _ic.text or ""'
    '';
  });
in

{
  home.packages = with pkgs; [
    ouch
  ];

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "yy";

    plugins = {
      git = pkgs.yaziPlugins.git;
      sudo = pkgs.yaziPlugins.sudo;
      piper = pkgs.yaziPlugins.piper;
      inherit yatline;
      smart-enter = pkgs.yaziPlugins.smart-enter;
      compress = pkgs.yaziPlugins.compress;
      ouch = pkgs.yaziPlugins.ouch;
    };
    initLua = builtins.readFile ./yatline-config.lua;

    theme.icon = {
      dirs = [
        { name = ".config"; text = ""; }
        { name = ".git"; text = ""; }
        { name = ".github"; text = ""; }
        { name = ".npm"; text = ""; }
        { name = "Desktop"; text = ""; }
        { name = "Development"; text = ""; }
        { name = "Documents"; text = ""; }
        { name = "Downloads"; text = ""; }
        { name = "Library"; text = ""; }
        { name = "Movies"; text = ""; }
        { name = "Music"; text = ""; }
        { name = "Pictures"; text = ""; }
        { name = "Public"; text = ""; }
        { name = "Videos"; text = ""; }
        { name = "nixos"; text = ""; }
        { name = "Archive"; text = ""; }
        { name = "Media"; text = ""; }
        { name = "Podcasts"; text = ""; }
        { name = "Drive"; text = ""; }
        { name = "KP"; text = ""; }
        { name = "Books"; text = ""; }
        { name = "Games"; text = ""; }
        { name = "Game Saves"; text = ""; }
        { name = "Templates"; text = ""; }
        { name = "Notes"; text = ""; }
        { name = "Projects"; text = ""; }
        { name = "Screenshots"; text = ""; }
      ];
    };

    keymap = {
      mgr.prepend_keymap = [
        # ── help ──
        # `?` normally does `find --previous`; remap it to the keybind cheatsheet
        # (built-in `~` / <F1> still work too). Find-previous moves to <A-/>.
        { run = "help"; on = [ "?" ]; desc = "Open help (all keybinds)"; }
        { run = "find --previous --smart"; on = [ "<A-/>" ]; desc = "Find previous file"; }

        # ── navigation ──
        { run = "cd ~/Projects"; on = [ "g" "p" ]; desc = "Go to projects"; }
        { run = "cd ~/Media/Pictures/Screenshots"; on = [ "g" "s" ]; desc = "Go to screenshots"; }
        { run = "cd --interactive"; on = [ "c" "d" ]; desc = "Jump to directory"; }
        { run = "plugin smart-enter"; on = [ "l" ]; desc = "Enter dir / open file"; }

        # ── open / execute ──
        { run = ''shell '${openWith} %s' --block''; on = [ "o" ]; desc = "Open with… (all apps)"; }
        {
          run = ''shell '${nvimOpen} %s' --block'';
          on = [ "e" ];
          desc = "Open in nvim";
        }
        { run = "shell ' %s' --cursor=0 --interactive --block"; on = [ "r" ]; desc = "Run command (blocking)"; }
        { run = "shell ' %s' --cursor=0 --interactive"; on = [ "R" ]; desc = "Run command (detached)"; }

        # ── archives ──
        { run = ''plugin compress -- -pls''; on = [ "c" "z" ]; desc = "Compress (password/level)"; }
        { run = "plugin ouch"; on = [ "c" "Z" ]; desc = "Compress with ouch"; }

        # ── yank / copy / paste ──
        { run = "yank"; on = [ "y" "y" ]; desc = "Yank"; }
        { run = "copy path"; on = [ "y" "p" ]; desc = "Copy path"; }
        { run = "copy dirname"; on = [ "y" "d" ]; desc = "Copy dirname"; }
        { run = "copy filename"; on = [ "y" "n" ]; desc = "Copy filename"; }
        { run = "copy name_without_ext"; on = [ "y" "N" ]; desc = "Copy name (no ext)"; }
        { run = "yank --cut"; on = [ "d" "d" ]; desc = "Cut"; }
        { run = "remove --force"; on = [ "d" "D" ]; desc = "Delete (force)"; }
        { run = "paste"; on = [ "p" "p" ]; desc = "Paste"; }
        { run = "paste --force"; on = [ "p" "P" ]; desc = "Paste (overwrite)"; }

        # ── sort ──
        { run = "sort mtime --reverse=no"; on = [ "s" "t" ]; desc = "Sort by mtime"; }
        { run = "sort mtime --reverse=yes"; on = [ "s" "T" ]; desc = "Sort by mtime (rev)"; }
        { run = "sort natural --reverse=no"; on = [ "s" "n" ]; desc = "Sort by name"; }
        { run = "sort natural --reverse=yes"; on = [ "s" "N" ]; desc = "Sort by name (rev)"; }
        { run = "sort alphabetical --reverse=no"; on = [ "s" "a" ]; desc = "Sort alphabetical"; }
        { run = "sort alphabetical --reverse=yes"; on = [ "s" "A" ]; desc = "Sort alphabetical (rev)"; }
        { run = "sort extension --reverse=no"; on = [ "s" "x" ]; desc = "Sort by extension"; }
        { run = "sort extension --reverse=yes"; on = [ "s" "X" ]; desc = "Sort by extension (rev)"; }
        { run = "sort size --reverse=no"; on = [ "s" "s" ]; desc = "Sort by size"; }
        { run = "sort size --reverse=yes"; on = [ "s" "S" ]; desc = "Sort by size (rev)"; }

        # ── tabs & UI ──
        { run = "tab_create --current"; on = [ "t" ]; }
        { run = "close"; on = [ "x" ]; }
        { run = "tab_switch 1 --relative"; on = [ "J" ]; }
        { run = "tab_switch 1 --relative"; on = [ "<C-Tab>" ]; }
        { run = "tab_switch -1 --relative"; on = [ "K" ]; }
        { run = "tab_switch -1 --relative"; on = [ "<C-BackTab>" ]; }
        { run = "undo"; on = [ "u" ]; }
        { run = "redo"; on = [ "<C-r>" ]; }
        { run = "hidden toggle"; on = [ "<C-h>" ]; desc = "Toggle hidden"; }

        # ── shell ──
        { run = "shell '$SHELL' --block"; on = [ "<C-t>" ]; desc = "Open shell here (exit to return)"; }
        { run = "shell ' %s' --cursor=0 --interactive"; on = [ "@" ]; desc = "Shell with selection"; }
      ];
    };

    settings = {
      opener = {
        text = [{ run = ''${nvimOpen} %s''; block = true; desc = "nvim"; }];
        image = [
          { run = ''xdg-open %s1''; orphan = true; desc = "Default (MIME)"; }
          { run = ''imv %s''; orphan = true; desc = "imv"; }
          { run = ''gimp %s''; orphan = true; desc = "GIMP"; }
        ];
        video = [
          { run = ''xdg-open %s1''; orphan = true; desc = "Default (MIME)"; }
          { run = ''mpv %s''; orphan = true; desc = "mpv"; }
        ];
        audio = [
          { run = ''xdg-open %s1''; orphan = true; desc = "Default (MIME)"; }
          { run = ''mpv %s''; orphan = true; desc = "mpv"; }
        ];
        document = [
          { run = ''zathura %s''; orphan = true; desc = "zathura"; }
          { run = ''xdg-open %s1''; orphan = true; desc = "Default (MIME)"; }
        ];
        archive = [
          { run = ''ouch d -y %s''; desc = "ouch (extract)"; }
        ];
      };
      open.rules = [
        # Directories opened from Yazi should become the nvim tree root.
        { url = "*/"; use = "text"; }

        # ── text MIME types ──
        { mime = "text/*"; use = "text"; }

        # ── application types that are text-based ──
        { mime = "application/json"; use = "text"; }
        { mime = "application/ld+json"; use = "text"; }
        { mime = "application/javascript"; use = "text"; }
        { mime = "application/xml"; use = "text"; }
        { mime = "application/xhtml+xml"; use = "text"; }
        { mime = "application/x-yaml"; use = "text"; }
        { mime = "application/x-shellscript"; use = "text"; }
        { mime = "application/x-python"; use = "text"; }
        { mime = "application/x-lua"; use = "text"; }
        { mime = "application/x-rust"; use = "text"; }
        { mime = "application/x-perl"; use = "text"; }
        { mime = "application/x-ruby"; use = "text"; }
        { mime = "application/x-php"; use = "text"; }
        { mime = "application/x-httpd-php"; use = "text"; }
        { mime = "application/x-awk"; use = "text"; }
        { mime = "application/x-sql"; use = "text"; }
        { mime = "application/x-desktop"; use = "text"; }
        { mime = "application/x-cmake"; use = "text"; }
        { mime = "application/x-meson"; use = "text"; }
        { mime = "application/x-toml"; use = "text"; }
        { mime = "application/x-dos-batch"; use = "text"; }

        # ── empty & special inodes ──
        { mime = "inode/x-empty"; use = "text"; }

        # ── images ──
        { mime = "image/*"; use = "image"; }
        { mime = "image/svg+xml"; use = "image"; }

        # ── video ──
        { mime = "video/*"; use = "video"; }

        # ── audio ──
        { mime = "audio/*"; use = "audio"; }

        # ── documents ──
        { mime = "application/pdf"; use = "document"; }
        { mime = "application/epub+zip"; use = "document"; }
        { mime = "application/x-fictionbook+xml"; use = "document"; }
        { mime = "application/vnd.comicbook+zip"; use = "document"; }
        { mime = "application/vnd.comicbook-rar"; use = "document"; }
        { mime = "application/x-djvu"; use = "document"; }

        # ── archives ──
        { mime = "application/zip"; use = "archive"; }
        { mime = "application/x-rar"; use = "archive"; }
        { mime = "application/vnd.rar"; use = "archive"; }
        { mime = "application/x-7z-compressed"; use = "archive"; }
        { mime = "application/x-tar"; use = "archive"; }
        { mime = "application/gzip"; use = "archive"; }
        { mime = "application/zstd"; use = "archive"; }
        { mime = "application/x-xz"; use = "archive"; }
        { mime = "application/x-bzip2"; use = "archive"; }
        { mime = "application/x-lz4"; use = "archive"; }
        { mime = "application/x-lzip"; use = "archive"; }
        { mime = "application/x-lzma"; use = "archive"; }
        { mime = "application/x-cpio"; use = "archive"; }
        { mime = "application/x-compress"; use = "archive"; }
        { mime = "application/vnd.debian.binary-package"; use = "archive"; }
        { mime = "application/x-rpm"; use = "archive"; }
        { mime = "application/x-java-archive"; use = "archive"; }
        { mime = "application/x-archive"; use = "archive"; }
        { mime = "application/x-cab"; use = "archive"; }

        # ── catch-all: everything else opens in nvim ──
        { url = "*"; use = "text"; }
      ];
      plugin.prepend_previewers = [
        { mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,lz4,java-archive,*archive}"; run = "ouch"; }
      ];
    };
  };
}
