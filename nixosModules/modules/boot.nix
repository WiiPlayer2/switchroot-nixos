{ pkgs, config, ... }:
{
  fileSystems = {
    "/boot" = {
      device = "/dev/mmcblk0p1";
      fsType = "vfat";
      noCheck = true;
    };
  };

  boot.loader.grub.enable = false;
  boot.loader.external = {
    enable = true;
    installHook =
      let
        switchroot-boot =
          (pkgs.switchroot-nixos {
            inherit (config.system.build) kernel initialRamdisk toplevel;
          }).boot;
        installApplication = pkgs.writeShellApplication {
          name = "install-boot-config";
          runtimeInputs = with pkgs; [
            uutils-coreutils-noprefix
            switchroot-boot.boot-scr.buildScript
          ];
          text = ''
            TOPLEVEL="$1"
            cp -v ${switchroot-boot.uImage} /boot/switchroot/nixos/uImage
            cp -v ${switchroot-boot.uInitrd} /boot/switchroot/nixos/initramfs
            cp -v ${switchroot-boot.dtb-image} /boot/switchroot/nixos/nx-plat.dtimg
            build-boot-scr "$TOPLEVEL" /boot/switchroot/nixos/boot.scr
          '';
        };
      in
      pkgs.lib.getExe installApplication;
  };
  system.build.switchrootImage = pkgs.switchroot-nixos {
    inherit (config.system.build) kernel initialRamdisk toplevel;
  };
}
