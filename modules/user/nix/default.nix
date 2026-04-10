{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # nil removed — nixd is more capable and actively maintained; configured as LSP in nvim/lsp.nix
    nixdoc
  ];
}
