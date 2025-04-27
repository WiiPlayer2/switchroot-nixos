{ pkgs, config, ... }:
{
        hardware.firmware = with pkgs; [
          config.boot.kernelPackages.kernel
          nvidiaPackages-l4t.tegra-firmware
        ];
        hardware.enableRedistributableFirmware = true;
        hardware.bluetooth.enable = true;
}
