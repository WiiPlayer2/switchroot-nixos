{ fetchFromGitHub, fetchFromGitLab, runCommand }:
rec {
  # https://gitlab.com/l4t-community
  # kernel sources
  switchroot-kernel-src = fetchFromGitLab {
    owner = "l4t-community";
    repo = "kernel/l4t-kernel-4.9";
    rev = "688864ead25c5643ec9ae997b08c06538e15c873";
    hash = "sha256-tJu1oY7/z0uv6NZOtuYse6LAJ8Pf764PmO5X6Lnoaz4=";
  };

  switchroot-kernel-nvidia-src = fetchFromGitLab {
    owner = "l4t-community";
    repo = "kernel/switch-l4t-kernel-nvidia";
    rev = "ed735c6dc5ceb52c4fcadc77e100ebede5bdd495";
    hash = "sha256-OMb3EcZ/CTCeKP/tTzSgiXkIJg/O4IlKppMtq4QuMuM=";
  };

  l4t-kernel-nvgpu-src = fetchFromGitLab {
    owner = "switchroot";
    repo = "kernel/l4t-kernel-nvgpu";
    rev = "1ae0167d360287ca78f5a2572f0de42594140312"; # r32.6.1
    hash = "sha256-SK/x/T2mMf9Kcz9rOXbyjPb84QqJf1QaD+lwSFQ+eq8=";
  };

  # device tree sources
  switchroot-platform-t210-nx-src = fetchFromGitHub {
    owner = "CTCaer";
    repo = "switch-l4t-platform-t210-nx";
    rev = "linux-5.1.2";
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
    rev = "d2692b96d3a89e26d3bad94eb7e6bc4caccbdbdb"; # r32.6.1
    hash = "sha256-uXBk9Rfbhxc8fBEJukwrcH5xNcA0hlEzAMSW9wQ3NIY=";
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
    rev = "1677f40a0b1bfa7c7273143b0f4944de28b73444"; # r32.6.1
    hash = "sha256-sEZ51GyLvtS8pYP3jxATZDCJ7mpUI02VL3zFeWN1w1M=";
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

    mkdir -p $out/kernel/hardware/nvidia/soc
    mkdir -p $out/kernel/hardware/nvidia/platform/{tegra,t210}
    ln -s ${l4t-soc-tegra-src} $out/kernel/hardware/nvidia/soc/tegra
    ln -s ${l4t-soc-t210-src} $out/kernel/hardware/nvidia/soc/t210
    ln -s ${l4t-platform-tegra-common-src} $out/kernel/hardware/nvidia/platform/tegra/common
    ln -s ${l4t-platform-t210-common-src} $out/kernel/hardware/nvidia/platform/t210/common
    ln -s ${switchroot-platform-t210-nx-src} $out/kernel/hardware/nvidia/platform/t210/nx
  '';
}
