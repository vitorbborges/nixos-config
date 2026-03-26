{ config, lib, pkgs, ... }:
{

    # Enable OpenGL
    hardware.graphics = {
        enable = true;
    };

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {

        # Modesetting is required
        modesetting.enable = true;

        # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
        # Enable this if you have graphical corruption issues or application crashes after waking
        # up from sleep. This fixes it by saving the entire  VRAM memory to /tmp/ instead
        # of just the bare essentials.
        # powerManagement.enable = false;

        # Fine-grained power management. Turns off GPU when not in use.
        # Experimental and only works on modern Nvidia GPUs (Turing or newer).
        powerManagement.finegrained = false;

        # Use the Nvidia  open source kernel module (not to be confused with the
        # independent third-party "nouveau" open source driver).
        # Support is limited to the Turing and later architectures. Full list of
        # supported GPUs is at:
        # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
        # Only available from drivers 515.43.04+
        open = false;

        # Enable the Nvidia settings menu,
        # accessible via `nvidia-settings`.
        nvidiaSettings = true;

        # Optionally, you may need to select the appropriate driver version for your specific GPU.
        package = config.boot.kernelPackages.nvidiaPackages.stable;

        # Nvidia Optimus PRIME for Hybrid GPU
        # Bus IDs confirmed from lspci: Intel iGPU at 0000:00:02.0, NVIDIA RTX 4070 at 0000:01:00.0
        # TODO: Implement PRIME with dynamic profile switching based on battery level.
        #
        # Recommended approach for this ASUS laptop:
        #   - services.supergfxd.enable + programs.rog-control-center.enable (via asusctl)
        #     ASUS-native GPU switching (integrated / hybrid / nvidia modes).
        #     supergfxctl can switch modes without a full reboot in some cases.
        #     Pairs with asusctl for fan curves and power profiles.
        #
        # Simpler cross-distro alternative:
        #   - programs.envycontrol (switch integrated/hybrid/nvidia modes, requires reboot)
        #
        # For CPU-side battery savings alongside PRIME offload:
        #   - services.auto-cpufreq.enable (CPU governor tuning on AC vs battery)
        #   - services.power-profiles-daemon.enable (power-saver/balanced/performance)
        #     Note: conflicts with auto-cpufreq, pick one.
        #
        # prime = {
            # offload mode: iGPU drives display, NVIDIA activated per-app via `nvidia-offload <app>`
            # offload.enable = true;
            # offload.enableOffloadCmd = true;

            # sync mode: NVIDIA always active, drives display (max performance, more power draw)
            # sync.enable = true;

            # intelBusId = "PCI:0:2:0";
            # nvidiaBusId = "PCI:1:0:0";
        # };
    };

    # Configuring VA-API hardware video acceleration
    hardware.graphics.extraPackages = with pkgs; [
        nvidia-vaapi-driver
    ];
}
