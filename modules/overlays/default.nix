final: prev: {
  awatcher = prev.rustPlatform.buildRustPackage rec {
    pname = "awatcher";
    version = "0.3.3";

    src = prev.fetchFromGitHub {
      owner = "2e3s";
      repo = "awatcher";
      rev = "678d7fd0867462f7925c1e4771994bba5f3da0c7";
      sha256 = "01gnc9vym2wcb9y5afhqix0p9cvdjdqqnhig823zqzwajvsdn11d";
    };

    cargoHash = "sha256-/dI0gaTRElAQnZNRo2sKMUc33fphubcG/fXOflPHXWs=";

    nativeBuildInputs = with prev; [
      pkg-config
    ];

    buildInputs = with prev; [
      openssl
      dbus
      libxkbcommon
      wayland
      libGL
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
