{
  description = "NixOS on Nintendo Switch";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-artwork = {
      url = "github:nixos/nixos-artwork";
      flake = false;
    };
  };

  outputs = inputs: {
    packages = import ./pkgs inputs;
    overlays = import ./overlays inputs;
    nixosConfigurations = import ./nixosConfigurations inputs;
  };
}
