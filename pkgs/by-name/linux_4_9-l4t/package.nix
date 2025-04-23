{ callPackage
, inputs

, ...
} @ args:
let
  sources = callPackage ./sources.nix {};
  kernel = callPackage ./kernel.nix ({ inherit sources; } // args);
in
  kernel
  # sources.combined-src
