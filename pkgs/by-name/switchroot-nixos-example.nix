{ switchroot-nixos
, linuxPackages_4_9-l4t

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

          boot.kernelPackages = linuxPackages_4_9-l4t;
          hardware.firmware = [ linuxPackages_4_9-l4t.kernel ];
          hardware.enableRedistributableFirmware = true;

          fileSystems = {
            "/" = {
              device = "/dev/disk/by-label/SWR-NIXOS";
              fsType = "ext4";
            };
          };

          # TODO: kernel should be usable without allowing missing modules
          nixpkgs.overlays = [
            (final: super: {
              makeModulesClosure = x:
                super.makeModulesClosure (x // { allowMissing = true; });
            })
          ];

          boot.loader.grub.enable = false;
          system.build.switchrootImage = switchroot-nixos {
            inherit (config.system.build) kernel initialRamdisk toplevel;
          };
        }
      )
    ];
  };
in
  nixosSystem.config.system.build.switchrootImage
