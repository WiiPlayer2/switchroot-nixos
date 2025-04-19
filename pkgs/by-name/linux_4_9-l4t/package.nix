{ callPackage
, inputs

, ...
} @ args:
let
  sources = callPackage ../l4t-kernel/sources.nix {};
  kernel = callPackage ./kernel.nix ({ inherit sources; } // args);
in
  kernel
  # sources.combined-src
