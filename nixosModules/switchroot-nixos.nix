inputs:
{ pkgs, ... }:
{
  imports = [
    ./modules/boot.nix
    ./modules/graphics.nix
    ./modules/hardware.nix
    ./modules/kernel.nix
    ./modules/sound.nix
  ];

  nixpkgs.overlays = [
    inputs.self.overlays.switchroot-nixos
  ];

  environment = {
    systemPackages = with pkgs; [
      nvidiaPackages-l4t.tools
    ];

    etc = {
      "nvpmodel/nvpmodel_charging.conf".source = "${pkgs.nvidiaPackages-l4t.nvpmodel-profiles}/etc/nvpmodel/nvpmodel_charging.conf";
      "nvpmodel/nvpmodel_t210.conf".source = "${pkgs.nvidiaPackages-l4t.nvpmodel-profiles}/etc/nvpmodel/nvpmodel_t210.conf";
      "nvpmodel/nvpmodel_t210b01.conf".source = "${pkgs.nvidiaPackages-l4t.nvpmodel-profiles}/etc/nvpmodel/nvpmodel_t210b01.conf";
    };
  };
}
