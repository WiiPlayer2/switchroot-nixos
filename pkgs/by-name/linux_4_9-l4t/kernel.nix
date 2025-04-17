{ sources
, callPackage
, inputs
, buildLinux
}:
let
  # buildLinux = callPackage ./buildLinux { inherit inputs; };
in
buildLinux rec {
  version = "4.9.140-l4t";
  modDirVersion = version;
  src = "${sources.combined-src}/kernel";
  # src = sources.combined-src;
  # sourceRoot = "${sources.combined-src.name}/kernel";
  defconfig = "tegra_linux_defconfig";
  enableCommonConfig = false;
}
