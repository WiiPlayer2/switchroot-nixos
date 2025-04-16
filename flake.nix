{
  description = "NixOS on Nintendo Switch";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs } @ inputs: {
    packages = import ./pkgs inputs;
  };
}
