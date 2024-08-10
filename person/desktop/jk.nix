{
  config,
  lib,
  home-manager,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../jk.nix
    ../../user/desktop/jk.nix
  ];
}
