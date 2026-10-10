{ pkgs, ... }:

let
  version = "0.4.0";

  # Upstream's release binaries dlopen Wayland/Vulkan/X11 at runtime — ldd
  # shows only libc/libgcc/libm — so those libs must reach them through
  # LD_LIBRARY_PATH or the app dies with "no backend" on NixOS.
  runtimeLibs = pkgs.lib.makeLibraryPath [
    pkgs.wayland
    pkgs.libxkbcommon
    pkgs.vulkan-loader
    pkgs.libglvnd
    pkgs.libx11
    pkgs.libxcursor
    pkgs.libxi
    pkgs.libxrandr
  ];

  # Repack of the upstream prebuilt .deb: it ships both the GUI (gridcraft)
  # and the agent CLI/MCP server (gridcraft-cli); upstream has no standalone
  # Linux CLI artifact. Bump with ./update-gridcraft.sh, not by hand.
  gridcraft = pkgs.stdenv.mkDerivation {
    pname = "gridcraft";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/storytold/gridcraft/releases/download/v${version}/gridcraft-${version}-linux-x86_64.deb";
      hash = "sha256-YCM2365SQ3IZfW/N/rHymz+tt+RLPPWOiZgvSmBkUe0=";
    };

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.dpkg
      pkgs.makeWrapper
    ];

    buildInputs = [ pkgs.stdenv.cc.cc.lib ];

    unpackPhase = ''
      dpkg-deb -x $src .
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r usr/. $out/

      for bin in gridcraft gridcraft-cli; do
        wrapProgram "$out/bin/$bin" \
          --prefix LD_LIBRARY_PATH : "${runtimeLibs}"
      done

      substituteInPlace $out/share/applications/ai.storyteller.gridcraft.desktop \
        --replace-fail "TryExec=gridcraft" "TryExec=$out/bin/gridcraft" \
        --replace-fail "Exec=gridcraft" "Exec=$out/bin/gridcraft"

      runHook postInstall
    '';

    meta = {
      description = "Open-source, clean-room Microsoft Excel-style spreadsheet (pre-alpha)";
      homepage = "https://github.com/storytold/gridcraft";
      license = with pkgs.lib.licenses; [ mit asl20 ];
      sourceProvenance = [ pkgs.lib.sourceTypes.binaryNativeCode ];
      platforms = [ "x86_64-linux" ];
      mainProgram = "gridcraft";
    };
  };
in
{
  home.packages = [ gridcraft ];
}
