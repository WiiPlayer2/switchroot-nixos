{ callPackage
, inputs
}:
let
  sources = callPackage ../l4t-kernel/sources.nix {};
  kernel = callPackage ./kernel.nix { inherit sources inputs; };
in
  kernel
  # sources.combined-src
