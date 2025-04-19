{ switchroot-nixos

, inputs
, system
}:
let
  nixosSystem = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      (
        { pkgs, config, ... }:
        {
          nixpkgs = {
            buildPlatform = system;
            hostPlatform = "aarch64-linux";
          };

          users.users.root.initialPassword = "nixos";
          services.openssh = {
            enable = true;
            settings.PermitRootLogin = "yes";
          };
          networking.networkmanager.enable = true;

          boot.kernelPackages = pkgs.linuxPackages_4_9-l4t;
          hardware.firmware = [ pkgs.linuxPackages_4_9-l4t.kernel ];
          hardware.enableRedistributableFirmware = true;

          fileSystems = {
            "/" = {
              device = "/dev/disk/by-label/SWR-NIXOS";
              fsType = "ext4";
            };
            "/boot" = {
              device = "/dev/mmcblk0p1";
              fsType = "vfat";
            };
          };

          # TODO: kernel should be usable without allowing missing modules
          nixpkgs.overlays = [
            inputs.self.overlays.switchroot-nixos
          ];

          boot.loader.grub.enable = false;
          system.build.switchrootImage = pkgs.switchroot-nixos {
            inherit (config.system.build) kernel initialRamdisk toplevel;
          };
        }
      )
    ];
  };
in
  nixosSystem.config.system.build.switchrootImage
