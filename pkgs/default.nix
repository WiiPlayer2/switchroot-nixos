{ nixpkgs, ... }:
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
  pkgsForSystem = system:
    let
      pkgs = import nixpkgs {
        localSystem = system;
        crossSystem = "aarch64-linux";
      };
      localPkgs = packagesFromDirectoryRecursive {
        callPackage = callPackageWith (pkgs // localPkgs);
        directory = ./by-name;
      };
    in
      localPkgs;
  pkgsSets =
    listToAttrs
    (
      map
      (system: {
        name = system;
        value = pkgsForSystem system;
      })
      supportedSystems
    );
in
  pkgsSets
