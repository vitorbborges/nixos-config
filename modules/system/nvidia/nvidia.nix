{ config, lib, pkgs, mesa263, ... }:
{

    # Enable OpenGL
    hardware.graphics = {
        enable = true;
        # Mesa 26.2.4 aborts in dri_create_fence_fd on this hybrid stack.
        # Pin only the runtime driver set to 26.2.3; app closures stay on 26.2.4.
        package = mesa263;
    };

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
        modesetting.enable = true;

        # RTX 4070 is Ada Lovelace — open module required since driver 560
        open = true;

        # Saves full VRAM to /tmp on suspend → prevents display corruption on wake
        powerManagement.enable = true;
        powerManagement.finegrained = false;

        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;

        # PRIME sync: NVIDIA always on, drives all rendering
        # Intel handles physical display output; NVIDIA does all compositing
        # Bus IDs confirmed via lspci on this machine
        prime = {
            sync.enable = true;
            intelBusId = "PCI:0:2:0";
            nvidiaBusId = "PCI:1:0:0";
        };
    };

    # Configuring VA-API hardware video acceleration
    hardware.graphics.extraPackages = with pkgs; [
        nvidia-vaapi-driver
    ];

    # ASUS hardware: fan curves, battery charge limit, keyboard RGB
    # Works alongside PRIME sync — does not manage GPU mode
    services.asusd.enable = true;
}
