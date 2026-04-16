{
  config,
  pkgs,
  ...
}: {
  # Install the required packages
  home.packages = with pkgs; [
    digikam
    qt6.qtwayland
  ];

  home.sessionVariables = {
    # Force Qt applications to use the Wayland platform plugin natively
    QT_QPA_PLATFORM = "wayland";
    # Tell ocl-icd where NixOS puts the NVIDIA OpenCL vendor ICD file.
    # Without this, ocl-icd finds no vendors and DigiKam reports "OpenCL not available".
    OCL_ICD_VENDORS = "/run/opengl-driver/etc/OpenCL/vendors/";
    # Select first GPU device for OpenCV OpenCL (tested working with RTX 4070)
    OPENCV_OPENCL_DEVICE = ":GPU:0";
    # Allow OpenCV DNN OpenCL path on all GPU devices (bypasses internal GPU-only type check)
    OPENCV_DNN_OPENCL_ALLOW_ALL_DEVICES = "1";
  };
}
