{ ... }:

{
  programs.nixvim.opts = {
    relativenumber = true;
    number = true;

    # Tabs & indentation
    tabstop = 2;
    shiftwidth = 2;
    expandtab = true;
    autoindent = true;

    wrap = false;

    # Search
    ignorecase = true;
    smartcase = true;

    cursorline = true;
    termguicolors = true;
    background = "dark";
    signcolumn = "yes";

    # Backspace
    backspace = "indent,eol,start";

    # Clipboard
    clipboard = "unnamedplus";

    # Splits
    splitright = true;
    splitbelow = true;

    swapfile = false;
  };

  programs.nixvim.globals.netrw_liststyle = 3;
}
