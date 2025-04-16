{ switchroot-nixos
, l4t-kernel

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
            hostPlatform = system;
            crossSystem = {
              system = "aarch64-linux";
            };
          };

          boot.kernelPackages = l4t-kernel;
          hardware.firmware = [ l4t-kernel.kernel ];
          hardware.enableRedistributableFirmware = true;

          # TODO: kernel should be usable without allowing missing modules
          nixpkgs.overlays = [
            (final: super: {
              makeModulesClosure = x:
                super.makeModulesClosure (x // { allowMissing = true; });
            })
          ];


          system.build.switchrootImage = switchroot-nixos {
            inherit (config.system.build) kernel initialRamdisk toplevel;
          };
        }
      )
    ];
  };
in
  nixosSystem.config.system.build.switchrootImage
