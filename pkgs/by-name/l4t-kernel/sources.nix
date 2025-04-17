{ fetchFromGitHub, fetchFromGitLab, runCommand }:
rec {
  # https://github.com/theofficialgman/l4t-image-buildscripts
  # kernel sources
  switchroot-kernel-src = fetchFromGitHub {
    owner = "theofficialgman";
    repo = "switch-l4t-kernel-4.9";
    rev = "6f926926d94a54aa6f9128234dd1a3833f6828d8";
    hash = "sha256-usEQGVq4HW4cRQpwSmq4VZeAzthuVaLgYjL38W2iafM=";
  };

  switchroot-kernel-nvidia-src = fetchFromGitHub {
    owner = "theofficialgman";
    repo = "switch-l4t-kernel-nvidia";
    rev = "76e6d48970b451c242c20f298b8d63027836bb0b";
    hash = "sha256-BNES5wSGUUJo2s9tx6IfZLzn+tzFbUEd8XZm+pEdQuk=";
  };

  l4t-kernel-nvgpu-src = fetchFromGitLab {
    owner = "switchroot";
    repo = "kernel/l4t-kernel-nvgpu";
    rev = "2c441a83d44857b71a599acfe76395942ea936bf"; # r32.6.1
    hash = "sha256-a/rZzYWIFQmg7hK7O778C2xRYhPuR2C8G3n/1IwSP6E=";
  };

  # device tree sources
  switchroot-platform-t210-nx-src = fetchFromGitHub {
    owner = "theofficialgman";
    repo = "switch-l4t-platform-t210-nx";
    rev = "cf785c4c176499b301170d79fe57b77f365b73cd";
    hash = "sha256-C2ShD5L111prt2GdoL7ZsScHav5Jmxhx5Ep2tMp/Tbc=";
  };

  l4t-soc-t210-src = fetchFromGitLab {
    owner = "switchroot";
    repo = "kernel/l4t-soc-t210";
    rev = "0d7816046cb06b637a3b70381a5e4994fd897c35"; # r32.6.1
    hash = "sha256-CcAxoGearjNNKDgB77oTKtmWDI+u358lAAvrJB9/sUE=";
  };

  l4t-soc-tegra-src = fetchFromGitLab {
    owner = "switchroot";
    repo = "kernel/l4t-soc-tegra";
    rev = "31df21b2d0039982fab538c740959d1ca68c4d37"; # r32.6.1
    hash = "sha256-17DsTlNnh7J+8pdiD7XdA5D1bNLBwhecql53dcajw2c=";
  };

  l4t-platform-t210-common-src = fetchFromGitLab {
    owner = "switchroot";
    repo = "kernel/l4t-platform-t210-common";
    rev = "846ce66ee941b49ff32bc721e4c8cc99eea2e979"; # r32.6.1
    hash = "sha256-QFNOTrFqzatnjZZzvAl9eq7R7bT+6s74fz+1sRpuAHM=";
  };

  l4t-platform-tegra-common-src = fetchFromGitLab {
    owner = "switchroot";
    repo = "kernel/l4t-platform-tegra-common";
    rev = "467507c8cb0de0b91ff28a97b9f18f3daf6230a5"; # r32.6.1
    hash = "sha256-s/ozD1NY+QegUWHoFqhF6KwU+Sds3JS2XS+boHEYGhw=";
  };

  combined-src = runCommand "combined-src" {} ''
    mkdir -p $out/kernel
    cp --no-preserve=mode -r ${switchroot-kernel-src}/* $out/kernel/
    sed -i 's/\/bin\/pwd/pwd/' $out/kernel/Makefile
    chmod +x $out/kernel/arch/arm64/kernel/vdso/gen_vdso_offsets.sh
    cp ${./gen-random-seed.sh} $out/kernel/scripts/gcc-plugins/gen-random-seed.sh

    mv $out/kernel/Makefile $out/kernel/Makefile.tmp
    cat > $out/kernel/Makefile.pre << EOF
    KERNEL_OVERLAYS :=
    KERNEL_OVERLAYS += ${switchroot-kernel-nvidia-src}
    KERNEL_OVERLAYS += ${l4t-kernel-nvgpu-src}
    EOF
    cat $out/kernel/Makefile.pre $out/kernel/Makefile.tmp > $out/kernel/Makefile

    mkdir -p $out/hardware/nvidia/soc
    mkdir -p $out/hardware/nvidia/platform/{tegra,t210}

    ln -s ${switchroot-kernel-nvidia-src} $out/nvidia
    ln -s ${l4t-kernel-nvgpu-src} $out/nvgpu
    ln -s ${l4t-soc-tegra-src} $out/hardware/nvidia/soc/tegra
    ln -s ${l4t-soc-t210-src} $out/hardware/nvidia/soc/t210
    ln -s ${l4t-platform-tegra-common-src} $out/hardware/nvidia/platform/tegra/common
    ln -s ${l4t-platform-t210-common-src} $out/hardware/nvidia/platform/t210/common
    ln -s ${switchroot-platform-t210-nx-src} $out/hardware/nvidia/platform/t210/nx
  '';
}
