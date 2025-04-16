{ callPackage
}:
let
  sources = callPackage ./sources.nix {};
  kernel = callPackage ./kernel.nix { inherit sources; };
in
  kernel
