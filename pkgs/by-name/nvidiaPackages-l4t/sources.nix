{ fetchzip
, runCommand
}:
let
  version = "32.6.1";
  driver-package = fetchzip {
    url = "https://developer.nvidia.com/embedded/l4t/r32_release_v6.1/t210/jetson-210_linux_r32.6.1_aarch64.tbz2";
    hash = "sha256-r6CA+3kAT37Pxh0zPIy1q0G4pq1w+bmtmS2UC867RGk=";
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
