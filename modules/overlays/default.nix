final: prev: {
  awatcher = prev.rustPlatform.buildRustPackage rec {
    pname = "awatcher";
    version = "unstable-2023-12-16";

    src = prev.fetchFromGitHub {
      owner = "2e3s";
      repo = "awatcher";
      rev = "312781b0460c5c678a1a4570075d9e5a1b32d294";
      sha256 = prev.lib.fakeSha256;
    };

    cargoSha256 = prev.lib.fakeHash;

    buildInputs = with prev; [
      pkg-config
      openssl
      dbus
    ];

    meta = with prev.lib; {
      description = "Window activity and idle watcher for ActivityWatch";
      homepage = "https://github.com/2e3s/awatcher";
      license = licenses.mpl20;
      platforms = platforms.linux;
      maintainers = [ ];
    };
  };
}
