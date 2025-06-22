{ callPackage }:
let
  sources = callPackage ./sources.nix { };
  tegra-lib = callPackage ./tegra-lib.nix {
    inherit (sources) nvidia-drivers;
  };
  tegra-firmware = callPackage ./tegra-firmware.nix {
    inherit (sources) nvidia-drivers;
  };
  x11-module = callPackage ./x11-module.nix {
    inherit (sources) nvidia-drivers;
    inherit tegra-lib;
  };
  tools = callPackage ./tools.nix {
    inherit (sources) nv-tools;
  };
  udev-rules = callPackage ./udev-rules.nix {
    inherit (sources) config;
  };
  alsa-config = callPackage ./alsa-config.nix {
    inherit (sources) config;
  };
  nvpmodel-profiles = callPackage ./nvpmodel-profiles { };
in
{
  inherit
    sources # TODO: remove
    x11-module
    tegra-firmware
    tegra-lib
    tools
    udev-rules
    alsa-config
    ;
}
