{ pkgs, lib }:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "awatcher";
  version = "unstable-2023-12-16"; # Placeholder version, can be updated

  src = pkgs.fetchFromGitHub {
    owner = "2e3s";
    repo = "awatcher";
    rev = "312781b0460c5c678a1a4570075d9e5a1b32d294"; # Latest commit hash at the time of writing
    sha256 = ""; # IMPORTANT: Replace with actual sha256 after first build attempt
  };

  cargoSha256 = ""; # IMPORTANT: Replace with actual cargoSha256 after first build attempt
  # To get the correct sha256 and cargoSha256, run a Nix build. It will fail
  # and provide the expected hashes in the error message. Replace lib.fakeSha256
  # and lib.fakeHash with those values.

  # Dependencies for building awatcher, based on README
  buildInputs = with pkgs; [
    pkg-config
    openssl
    dbus
  ];

  # This is based on the build instructions "cargo build --release"
  # No specific install phase mentioned, so default should work if it places the binary in $out/bin
  # If awatcher binary is not in $out/bin, add a custom installPhase like:
  # installPhase = ''
  #   mkdir -p $out/bin
  #   cp target/release/awatcher $out/bin/
  # '';

  meta = with lib; {
    description = "Window activity and idle watcher for ActivityWatch";
    homepage = "https://github.com/2e3s/awatcher";
    license = licenses.mpl20; # Assuming MPL-2.0 from project's README
    platforms = platforms.linux;
    maintainers = [ ]; # No specific maintainers mentioned
  };
}