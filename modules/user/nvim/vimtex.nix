{ pkgs, ... }:

{
  programs.nixvim.plugins.vimtex = {
    enable = true;

    settings = {
      # sioyek viewer: Wayland-native, LaTeX-aware auto-reload, no xdotool/DBus
      view_method = "sioyek";
    };

    # VimTeX's default latexmk backend needs the TeX env on PATH inside nvim.
    # Same store path as home.packages texliveFull in latex/latex.nix.
    texlivePackage = pkgs.texliveFull;
  };

  # VimTeX registers its <localleader> mappings without desc attributes, so
  # which-key cannot show them. These spec entries register the LaTeX group
  # and attach descriptions to VimTeX's existing mappings — nothing is
  # remapped here. Keys verified against vimtex 2.18 s:init_default_mappings.
  programs.nixvim.plugins.which-key.settings.spec = [
    { __unkeyed-1 = "<localleader>"; group = "LaTeX"; }
    { __unkeyed-1 = "<localleader>l"; group = "Compile"; }
    { __unkeyed-1 = "<localleader>v"; group = "View"; }
    { __unkeyed-1 = "<localleader>t"; group = "TOC"; }

    { __unkeyed-1 = "<localleader>ll"; desc = "Continuous compile"; }
    { __unkeyed-1 = "<localleader>lS"; desc = "Single-shot compile"; }
    { __unkeyed-1 = "<localleader>lL"; desc = "Compile selection"; }
    { __unkeyed-1 = "<localleader>lk"; desc = "Stop compile"; }
    { __unkeyed-1 = "<localleader>lK"; desc = "Stop all compiles"; }
    { __unkeyed-1 = "<localleader>le"; desc = "Errors (quickfix)"; }
    { __unkeyed-1 = "<localleader>lo"; desc = "Compiler output"; }
    { __unkeyed-1 = "<localleader>lc"; desc = "Clean auxiliary files"; }
    { __unkeyed-1 = "<localleader>lC"; desc = "Clean all generated"; }
    { __unkeyed-1 = "<localleader>lg"; desc = "Compile status"; }
    { __unkeyed-1 = "<localleader>lG"; desc = "All compile statuses"; }
    { __unkeyed-1 = "<localleader>lq"; desc = "View log"; }

    { __unkeyed-1 = "<localleader>lv"; desc = "View PDF / forward search"; }
    { __unkeyed-1 = "<localleader>lr"; desc = "Inverse search (from PDF)"; }

    { __unkeyed-1 = "<localleader>lt"; desc = "Open TOC"; }
    { __unkeyed-1 = "<localleader>lT"; desc = "Toggle TOC"; }

    { __unkeyed-1 = "<localleader>li"; desc = "Project info"; }
    { __unkeyed-1 = "<localleader>lI"; desc = "Full project info"; }
    { __unkeyed-1 = "<localleader>ls"; desc = "Toggle main file"; }
    { __unkeyed-1 = "<localleader>la"; desc = "Context menu"; }
    { __unkeyed-1 = "<localleader>lm"; desc = "List imaps"; }
    { __unkeyed-1 = "<localleader>lx"; desc = "Reload plugin"; }
    { __unkeyed-1 = "<localleader>lX"; desc = "Reload plugin state"; }
  ];
}
