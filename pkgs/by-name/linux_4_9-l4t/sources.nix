{ fetchFromGitHub
, fetchFromGitLab
, runCommand
}:
let
  kernel_rev = "linux-dev";
  devicetree_rev = "l4t/l4t-r32.5";
  nx_rev = "linux-dev";
  nv_rev = "linux-dev";
  nvgpu_rev = "linux-3.4.0-r32.5";
in rec {
  # https://github.com/theofficialgman/l4t-image-buildscripts
  # kernel sources
  switch-l4t-kernel-4_9-src = fetchFromGitHub {
    owner = "theofficialgman";
    repo = "switch-l4t-kernel-4.9";
    rev = kernel_rev;
    hash = "sha256-usEQGVq4HW4cRQpwSmq4VZeAzthuVaLgYjL38W2iafM=";
  };

  switch-l4t-kernel-nvidia-src = fetchFromGitHub {
    owner = "CTCaer";
    repo = "switch-l4t-kernel-nvidia";
    rev = nv_rev;
    hash = "sha256-BNES5wSGUUJo2s9tx6IfZLzn+tzFbUEd8XZm+pEdQuk=";
  };

  l4t-kernel-nvgpu-src = fetchFromGitLab {
    owner = "switchroot";
    repo = "kernel/l4t-kernel-nvgpu";
    rev = nvgpu_rev;
    hash = "sha256-SK/x/T2mMf9Kcz9rOXbyjPb84QqJf1QaD+lwSFQ+eq8=";
  };

  # device tree sources
  switchroot-platform-t210-nx-src = fetchFromGitHub {
    owner = "CTCaer";
    repo = "switch-l4t-platform-t210-nx";
    rev = nx_rev;
    hash = "sha256-C2ShD5L111prt2GdoL7ZsScHav5Jmxhx5Ep2tMp/Tbc=";
  };

  l4t-soc-t210-src = fetchFromGitLab {
    owner = "switchroot";
    repo = "kernel/l4t-soc-t210";
    rev = devicetree_rev;
    hash = "sha256-CcAxoGearjNNKDgB77oTKtmWDI+u358lAAvrJB9/sUE=";
  };

  l4t-soc-tegra-src = fetchFromGitLab {
    owner = "switchroot";
    repo = "kernel/l4t-soc-tegra";
    rev = devicetree_rev;
    hash = "sha256-uXBk9Rfbhxc8fBEJukwrcH5xNcA0hlEzAMSW9wQ3NIY=";
  };

  l4t-platform-t210-common-src = fetchFromGitLab {
    owner = "switchroot";
    repo = "kernel/l4t-platform-t210-common";
    rev = devicetree_rev;
    hash = "sha256-QFNOTrFqzatnjZZzvAl9eq7R7bT+6s74fz+1sRpuAHM=";
  };

  l4t-platform-tegra-common-src = fetchFromGitLab {
    owner = "switchroot";
    repo = "kernel/l4t-platform-tegra-common";
    rev = devicetree_rev;
    hash = "sha256-sEZ51GyLvtS8pYP3jxATZDCJ7mpUI02VL3zFeWN1w1M=";
  };

  combined-src = runCommand "combined-src" {} ''
    mkdir -p $out/kernel
    cp --no-preserve=mode -r ${switch-l4t-kernel-4_9-src}/* $out/kernel/
    sed -i 's/\/bin\/pwd/pwd/' $out/kernel/Makefile
    chmod +x $out/kernel/arch/arm64/kernel/vdso/gen_vdso_offsets.sh
    cp ${./gen-random-seed.sh} $out/kernel/scripts/gcc-plugins/gen-random-seed.sh

    # mv $out/kernel/Makefile $out/kernel/Makefile.tmp
    # cat > $out/kernel/Makefile.pre << EOF
    # KERNEL_OVERLAYS :=
    # KERNEL_OVERLAYS += ${switch-l4t-kernel-nvidia-src}
    # KERNEL_OVERLAYS += ${l4t-kernel-nvgpu-src}
    # EOF
    # cat $out/kernel/Makefile.pre $out/kernel/Makefile.tmp > $out/kernel/Makefile

    # (echo "dts-dirs += nvidia"; cat $out/kernel/arch/arm64/boot/dts/Makefile) > $out/kernel/arch/arm64/boot/dts/Makefile.tmp
    # mv $out/kernel/arch/arm64/boot/dts/Makefile.tmp $out/kernel/arch/arm64/boot/dts/Makefile

    mkdir -p $out/hardware/nvidia/soc
    mkdir -p $out/hardware/nvidia/platform/{tegra,t210}

    ln -s ${switch-l4t-kernel-nvidia-src} $out/nvidia
    ln -s ${l4t-kernel-nvgpu-src} $out/nvgpu
    ln -s ${l4t-soc-tegra-src} $out/hardware/nvidia/soc/tegra
    ln -s ${l4t-soc-t210-src} $out/hardware/nvidia/soc/t210
    ln -s ${l4t-platform-tegra-common-src} $out/hardware/nvidia/platform/tegra/common
    ln -s ${l4t-platform-t210-common-src} $out/hardware/nvidia/platform/t210/common
    ln -s ${switchroot-platform-t210-nx-src} $out/hardware/nvidia/platform/t210/nx

    mkdir -p $out/kernel/nvidia/soc
    mkdir -p $out/kernel/nvidia/platform/{tegra,t210}
    ln -s ${l4t-soc-tegra-src} $out/kernel/nvidia/soc/tegra
    ln -s ${l4t-soc-t210-src} $out/kernel/nvidia/soc/t210
    ln -s ${l4t-platform-tegra-common-src} $out/kernel/nvidia/platform/tegra/common
    ln -s ${l4t-platform-t210-common-src} $out/kernel/nvidia/platform/t210/common
    ln -s ${switchroot-platform-t210-nx-src} $out/kernel/nvidia/platform/t210/nx

    mkdir -p $out/kernel/nvidia/nvgpu
    cp --no-preserve=mode -r ${switch-l4t-kernel-nvidia-src}/* $out/kernel/nvidia/
    cp --no-preserve=mode -r ${l4t-kernel-nvgpu-src}/* $out/kernel/nvidia/nvgpu/
  '';
}
