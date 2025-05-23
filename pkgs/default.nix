{ nixpkgs, ... }@inputs:
let
  supportedSystems = [
    "aarch64-linux"
    "x86_64-linux"
  ];
  inherit (nixpkgs.lib)
    map
    listToAttrs
    packagesFromDirectoryRecursive
    callPackageWith
    ;
  pkgsForSystem =
    system:
    let
      pkgs = import nixpkgs {
        # inherit system;
        localSystem = system;
        crossSystem = "aarch64-linux";
      };
      additionalDependencies = {
        inherit inputs;
      };
      localPkgs = packagesFromDirectoryRecursive {
        callPackage = callPackageWith (pkgs // additionalDependencies // localPkgs);
        directory = ./by-name;
      };
    in
    localPkgs;
  pkgsSets = listToAttrs (
    map (system: {
      name = system;
      value = pkgsForSystem system;
    }) supportedSystems
  );
in
pkgsSets
