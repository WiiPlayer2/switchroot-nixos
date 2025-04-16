{ callPackage
, stdenv
, lib
}:
let
  sources = callPackage ./sources.nix {};
  kernel = callPackage ./kernel.nix { inherit sources; };
in
lib.makeExtensible (final: {
  inherit kernel;
  stdenv = stdenv;
  kernelAtLeast = lib.versionAtLeast "4.9";
})

