{
  config,
  lib,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [];

  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    initrd = {
      availableKernelModules = [
        "applespi"
        "applesmc"
        "spi_pxa2xx_platform"
        "intel_lpss_pci"
      ];
    };
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    enableB43Firmware = true;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    mbpfan.enable = true;
  };
}
