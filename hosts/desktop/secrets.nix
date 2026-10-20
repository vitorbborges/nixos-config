{ username, ... }:

{
  # Decryption key is the user's existing age key, not nix-managed and not in
  # git. Secrets land in /run/secrets, readable only by the user.
  sops.age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
  sops.defaultSopsFile = ./secrets.yaml;

  sops.secrets.smtp_password = {
    owner = username;
    mode = "0400";
  };
}
