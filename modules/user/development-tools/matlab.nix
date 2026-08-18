{ ... }:
{
  home.sessionVariables.MATLAB_INSTALL_DIR = "/home/vitor/MATLAB/R2026a";

  home.file.".local/bin/matlab" = {
    executable = true;
    source = ./scripts/matlab-podman.sh;
  };

  xdg.desktopEntries.matlab = {
    name = "MATLAB R2026a";
    comment = "MATLAB computational environment";
    exec = "/home/vitor/.local/bin/matlab";
    icon = "/home/vitor/MATLAB/R2026a/bin/glnxa64/cef_resources/matlab_icon.png";
    terminal = false;
    categories = [ "Science" "Math" "Education" ];
    startupNotify = true;
  };
}
