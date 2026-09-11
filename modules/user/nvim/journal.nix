{ ... }:

{
  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<leader>jj";
      action.__raw = builtins.readFile ./lua/journal-open.lua;
      options.desc = "Open today's daily journal";
    }
    {
      mode = "n";
      key = "<leader>jt";
      action.__raw = builtins.readFile ./lua/journal-entry.lua;
      options.desc = "Insert timestamped journal entry";
    }
  ];
}
