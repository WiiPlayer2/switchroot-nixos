{ fetchzip
, runCommand
}:
let
  driver-package = fetchzip {
    url = "https://developer.nvidia.com/embedded/l4t/r32_release_v6.1/t210/jetson-210_linux_r32.6.1_aarch64.tbz2";
    hash = "sha256-r6CA+3kAT37Pxh0zPIy1q0G4pq1w+bmtmS2UC867RGk=";
  };
  nvidia-drivers = runCommand "nvidia_drivers" {} ''
    mkdir $out
    cd $out
    tar -xjf ${driver-package}/nv_tegra/nvidia_drivers.tbz2
  '';
in
{
  inherit
    driver-package
    nvidia-drivers
    ;
}
