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
  };

  # Disable PulseAudio — conflicts with PipeWire
  services.pulseaudio.enable = false;

  # Real-time priority for audio threads (low-latency)
  security.rtkit.enable = true;
}
