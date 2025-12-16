final: prev: {
  awatcher = (import ../system/awatcher-package.nix) { pkgs = prev; lib = prev.lib; };
}