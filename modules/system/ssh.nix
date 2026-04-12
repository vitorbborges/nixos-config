{ pkgs, ... }:

{
  programs.ssh = {
    startAgent = false;
    askPassword = "${pkgs.gcr_4}/libexec/gcr-ssh-askpass";
    knownHosts = {
      "github.com" = {
        hostNames = [ "github.com" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      };
    };
  };
}
