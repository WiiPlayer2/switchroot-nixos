{ nvidia-drivers
, runCommand

, tegra-lib
, iconv
}:
runCommand "nvidia-l4t-x11-module" {} ''
  mkdir -p $out/lib
  cp --no-preserve=mode -r ${nvidia-drivers}/usr/lib/xorg $out/lib
  patchelf \
    --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
    --set-rpath ${iconv}/lib:${tegra-lib}/lib \
    $out/lib/xorg/modules/drivers/nvidia_drv.so
''
# libnvidia-rmapi-tegra.so.32.6.1
# libm.so.6
# libc.so.6
# libdl.so.2
