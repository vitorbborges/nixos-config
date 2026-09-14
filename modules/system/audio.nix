{ ... }:

{
  # PipeWire: modern audio backend replacing PulseAudio/JACK/ALSA
  services.pipewire = {
    enable = true;
    alsa.enable = true;        # ALSA compatibility
    alsa.support32Bit = true;  # 32-bit app support (games, wine)
    pulse.enable = true;       # PulseAudio compatibility
    jack.enable = true;        # JACK compatibility (DAW, pro audio)
    wireplumber.enable = true; # session/policy manager

    # MAXHUB/ExceedShare's recorder ("ShareRecord") asks for a 2 s buffer by
    # default; cap it at ~20 ms so mirrored audio stays in sync with video.
    extraConfig."pipewire-pulse"."50-sharerecord-latency" = {
      "pulse.rules" = [
        {
          matches = [ { "application.name" = "ShareRecord"; } ];
          actions."update-props" = {
            "pulse.default.frag" = "960/48000";
            "pulse.default.tlength" = "960/48000";
            "pulse.min.req" = "256/48000";
          };
        }
      ];
    };

    # The snd-dummy card is only a capture target for ExceedShare, never a
    # sensible auto-selected default. Zeroing its session priority keeps
    # WirePlumber's default-node policy from ever landing on it (silent audio)
    # after the projector-audio-watch service clears the default pins.
    wireplumber.extraConfig."51-dummy-not-default" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            { "node.name" = "alsa_output.platform-snd_dummy.0.stereo-fallback"; }
            { "node.name" = "alsa_input.platform-snd_dummy.0.stereo-fallback"; }
          ];
          actions."update-props"."session.priority" = 0;
        }
      ];
    };
  };

  # Virtual sound card the ExceedShare client captures system audio from
  # (apps play to it while casting; the client records its monitor).
  boot.kernelModules = [ "snd-dummy" ];

  # Disable PulseAudio — conflicts with PipeWire
  services.pulseaudio.enable = false;

  # Real-time priority for audio threads (low-latency)
  security.rtkit.enable = true;
}
