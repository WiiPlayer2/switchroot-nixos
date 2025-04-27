{
  fetchzip,
  runCommand,
}:
let
  # https://developer.nvidia.com/embedded/l4t-3231-archive
  version = "32.3.1";
  driver-package = fetchzip {
    url = "https://developer.nvidia.com/embedded/dlc/r32-3-1_Release_v1.0/t210ref_release_aarch64/Tegra210_Linux_R32.3.1_aarch64.tbz2";
    hash = "sha256-UfPjgonDPMhxQMp/tlwo9NODIDd6rmXfwFJGNarQyMk=";
  };
  nvidia-drivers =
    runCommand "nvidia_drivers"
      {
        passthru.version = version;
      }
      ''
        mkdir $out
        cd $out
        tar -xjf ${driver-package}/nv_tegra/nvidia_drivers.tbz2
      '';
  nv-tools =
    runCommand "nvidia_tools"
      {
        passthru.version = version;
      }
      ''
        mkdir $out
        cd $out
        tar -xjf ${driver-package}/nv_tegra/nv_tools.tbz2
      '';
  config =
    runCommand "config"
      {
        passthru.version = version;
      }
      ''
        mkdir $out
        cd $out
        tar -xjf ${driver-package}/nv_tegra/config.tbz2
      '';
in
{
  inherit
    driver-package
    nvidia-drivers
    nv-tools
    config
    ;
}
