{ config, pkgs, home-manager, ... }:

{
    programs.git = {
        enable = true;
        settings.user.name = "vitorbborges";
        settings.user.email = "vitorbborges31@gmail.com";
        settings.init.defaultBranch = "main";
        lfs.enable = true;
    };

    programs.lazygit = {
        enable = true;
        # TODO: Configure lazygit.
    };

    programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks = {
            "github.com" = {
                identityFile = "~/.ssh/id_ed25519";
            };
        };
    };

    home.packages = with pkgs; [
        git
        openssh
    ];
}
