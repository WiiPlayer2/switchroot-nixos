inputs:
{
  imports = [
    ./modules/boot.nix
    ./modules/graphics.nix
  ];

  nixpkgs.overlays = [
    inputs.self.overlays.switchroot-nixos
  ];
}
