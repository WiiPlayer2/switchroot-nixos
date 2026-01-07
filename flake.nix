{
  description = "NixOS on Nintendo Switch";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-pinned.url = "github:nixos/nixpkgs?ref=1242ee333dd7063e6d57ee1996a2e0504a28de16"; # systemd: 257.9
    nixos-artwork = {
      url = "github:nixos/nixos-artwork";
      flake = false;
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      deploy-rs,
      nixpkgs,
      ...
    }@inputs:
    {
      packages = import ./pkgs inputs;
      overlays = import ./overlays inputs;
      nixosConfigurations = import ./nixosConfigurations inputs;
      nixosModules = import ./nixosModules inputs;

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
      deploy.nodes.default = {
        hostname = "nintendo-switch";
        profiles.system = {
          sshUser = "root";
          path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.example;
        };
      };
    };
}
