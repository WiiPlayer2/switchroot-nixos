{ callPackage }:
let
  sources = callPackage ./sources.nix {};
  tegra-lib = callPackage ./tegra-lib.nix {
    inherit (sources) nvidia-drivers;
  };
  x11-module = callPackage ./x11-module.nix {
    inherit (sources) nvidia-drivers;
    inherit tegra-lib;
  };
in
{
  inherit
    sources # TODO: remove
    x11-module
    ;
}
