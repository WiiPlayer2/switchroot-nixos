{ nixpkgs, ... }:
let
  supportedSystems = [
    "aarch64-linux"
  ];
  inherit (nixpkgs.lib)
    map
    listToAttrs
    ;
  pkgsForSystem = system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      null;
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
