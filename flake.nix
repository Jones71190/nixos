{
  description = "nixos flake mpaepcke";
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/master";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:paepckehh/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-hardware,
  }: {
    nixosConfigurations = {
      #################
      # GENERIC NIXOS #
      #################
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./desktop/gnome.nix
          ./person/desktop/mpp.nix
          ./modules/office.nix
          {networking.hostName = "nixos";}
        ];
      };
      nixos-console = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./person/mpp.nix
          {networking.hostName = "nixos-console";}
        ];
      };
      nixos-iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
          {networking.hostName = "nixos-iso";}
        ];
      };
      ###########################################
      # APPLE MacBookPro14,1 / UK int. Keyboard #
      ###########################################
      nixbook141 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.apple-macbook-pro-14-1
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./desktop/gnome.nix
          ./person/desktop/mpp.nix
          ./modules/office.nix
          {networking.hostName = "nixbook141";}
        ];
      };
      nixbook141-hyprland = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.apple-macbook-pro-14-1
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./desktop/hyprland.nix
          ./person/desktop/mpp.nix
          ./modules/office.nix
          {networking.hostName = "nixbook141-hyprland";}
        ];
      };
    };
  };
}
