{ callPackage
, system
, inputs

, ...
} @ args:
let
  sources = callPackage ./sources.nix {};
  kernel = callPackage ./kernel.nix ({ inherit sources; } // args);
  kernelCross =
    let
      pkgsCross = import inputs.nixpkgs {
          localSystem = "x86_64-linux";
          crossSystem = system;
      };
    in
      pkgsCross.callPackage ./kernel.nix ({ inherit sources; } // args);
in
  kernel // {
    cross-compiled = kernelCross;
  }
  # sources.combined-src
