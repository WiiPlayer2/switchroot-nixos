inputs:
{
  imports = [
    ./modules/boot.nix
  ];

  nixpkgs.overlays = [
    inputs.self.overlays.switchroot-nixos
  ];
}
