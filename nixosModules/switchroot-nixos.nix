inputs:
{
  imports = [
    ./modules/boot.nix
    ./modules/graphics.nix
    ./modules/sound.nix
  ];

  nixpkgs.overlays = [
    inputs.self.overlays.switchroot-nixos
  ];
}
