{ pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_4_9-l4t.cross-compiled;
}
