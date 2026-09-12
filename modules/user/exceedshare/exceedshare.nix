{ pkgs, ... }:

let
  # The bundled Qt5/xcb plugins are built against a generic FHS distro, so the
  # wrapper supplies the missing system libraries (X11, GL, udev, PipeWire for
  # the screen-cast portal) while the app's own lib/ dir keeps taking priority.
  libPath = pkgs.lib.makeLibraryPath (
    with pkgs;
    [
      stdenv.cc.cc.lib # libstdc++ / libgcc_s
      udev # libudev
      xorg.libX11
      xorg.libxcb
      xorg.libXau
      xorg.libXdmcp
      xorg.libXext
      xorg.libXrender
      xorg.libXfixes
      xorg.libXrandr
      xorg.libXcursor
      xorg.libXi
      xorg.libXinerama
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXtst
      xorg.libSM
      xorg.libICE
      xorg.libXScrnSaver
      xorg.libXxf86vm
      xorg.xcbutil
      xorg.xcbutilimage
      xorg.xcbutilkeysyms
      xorg.xcbutilrenderutil
      xorg.xcbutilwm
      xorg.xcbutilcursor
      libxkbcommon
      fontconfig
      freetype
      expat
      libglvnd
      mesa # libgbm
      libgpg-error
      openssl
      libffi
      zlib
      libpng
      libjpeg
      pipewire # libpipewire-0.3.so.0 (Wayland screen capture)
    ]
  );

  exceedshare = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "exceedshare";
    version = "5.10.45.0";

    src = pkgs.fetchurl {
      url = "https://github.com/panmingjun/maxhub-exceedshare/releases/download/${finalAttrs.version}/com.cvte.exceedshare_${finalAttrs.version}_amd64.deb";
      hash = "sha256-he9Q+8IFaxNDH81M2OdtE2opGPyLhpWl1AoiVLpa/kQ=";
    };

    nativeBuildInputs = with pkgs; [
      binutils
      xz
      makeWrapper
    ];

    unpackPhase = ''
      runHook preUnpack
      ar x "$src"
      tar -xf data.tar.xz
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/libexec/exceedshare
      cp -r opt/apps/com.cvte.exceedshare/files/. $out/libexec/exceedshare/

      mkdir -p $out/share/icons/hicolor/scalable/apps
      cp ${./icon.svg} $out/share/icons/hicolor/scalable/apps/exceedshare.svg

      mkdir -p $out/share/applications
      cp ${./exceedshare.desktop} $out/share/applications/exceedshare.desktop

      makeWrapper $out/libexec/exceedshare/bin/ExceedShare $out/bin/exceedshare \
        --prefix LD_LIBRARY_PATH : "$out/libexec/exceedshare/lib:${libPath}" \
        --prefix QT_PLUGIN_PATH : "$out/libexec/exceedshare/plugins" \
        --set QT_QPA_PLATFORM "xcb;wayland"

      runHook postInstall
    '';

    meta = {
      description = "MAXHUB/ExceedShare wireless screen sharing client (binary release)";
      homepage = "https://excshare.com";
      platforms = [ "x86_64-linux" ];
      sourceProvenance = [ pkgs.lib.sourceTypes.binaryNativeCode ];
      license = pkgs.lib.licenses.unfree;
    };
  });

  # Watches for the client's "ShareRecord" capture stream and switches the
  # default sink/source to the virtual device while casting, so projector
  # audio is automatic (and the laptop speakers come back when casting stops).
  projector-audio-watch = pkgs.writeShellApplication {
    name = "projector-audio-watch";
    runtimeInputs = with pkgs; [ pulseaudio ];
    text = builtins.readFile ./scripts/projector-audio-watch.sh;
  };
in
{
  home.packages = [ exceedshare ];

  systemd.user.services.projector-audio-watch = {
    Unit = {
      Description = "Route system audio to the ExceedShare virtual sink while casting";
      After = [ "pipewire-pulse.service" ];
    };
    Service = {
      ExecStart = "${projector-audio-watch}/bin/projector-audio-watch";
      Restart = "always";
      RestartSec = 2;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
