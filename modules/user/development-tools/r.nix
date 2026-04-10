{ config, pkgs, pkgs-stable, ... }:

let
  myRPackages = with pkgs.rPackages; [
    ggplot2
    dplyr
    # Add other desired R packages here
  ];

  R-with-my-packages = pkgs.rWrapper.override {
    packages = myRPackages;
  };

  RStudio-with-my-packages = pkgs-stable.rstudioWrapper.override {
    packages = with pkgs-stable.rPackages; [
      ggplot2
      dplyr
    ];
  };

in {
  home.packages = with pkgs; [
    R-with-my-packages
    RStudio-with-my-packages
    # If you also need a plain R without specific packages, you can add pkgs.R here
  ];
}
