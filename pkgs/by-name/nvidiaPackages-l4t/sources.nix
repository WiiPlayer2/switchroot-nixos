{ fetchzip
, runCommand
}:
let
  version = "32.5.2";
  driver-package = fetchzip {
    url = "https://developer.nvidia.com/embedded/l4t/r32_release_v5.2/t210/jetson-210_linux_r32.5.2_aarch64.tbz2";
    hash = "sha256-dQK9QbibjGgqXdLXqAkGsfK1reqvQIz9NHJEUnM5lFI=";
  };
  nvidia-drivers = runCommand "nvidia_drivers" {
    passthru.version = version;
  } ''
    mkdir $out
    cd $out
    tar -xjf ${driver-package}/nv_tegra/nvidia_drivers.tbz2
  '';
  nv-tools = runCommand "nvidia_drivers" {
    passthru.version = version;
  } ''
    mkdir $out
    cd $out
    tar -xjf ${driver-package}/nv_tegra/nv_tools.tbz2
  '';
in
{
  inherit
    driver-package
    nvidia-drivers
    nv-tools
    ;
}
