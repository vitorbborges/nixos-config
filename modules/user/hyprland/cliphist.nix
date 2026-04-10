{ ... }:

{
  # Daemon: watches clipboard and stores text + images into SQLite history
  services.cliphist = {
    enable = true;
    allowImages = true;
    extraOptions = [
      "-max-dedupe-search" "100"
      "-max-items" "750"
    ];
  };
}
