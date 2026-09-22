{ pkgs, ... }:

{
  # Plain extension-free Firefox, one of the browsers accepted by CISIA for
  # TEST ITA L2 @HOME (23-09-2026). Zen is a Firefox fork but not an accepted
  # browser and force-loads extensions that can interfere with test platforms.
  home.packages = [ pkgs.firefox ];
}
