{ nixpkgs, ... }:
let
  supportedSystems = [
    "aarch64-linux"
  ];
  inherit (nixpkgs.lib)
    map
    listToAttrs
    packagesFromDirectoryRecursive
    callPackageWith
    ;
  pkgsForSystem = system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
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
