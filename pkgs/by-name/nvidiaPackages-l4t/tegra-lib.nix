{
  nvidia-drivers,
  runCommand,
  writers,
  stdenv,
  autoPatchelfHook,
  libgcc,
  libglvnd,
  glib,
  alsa-lib,
  cairo,
  pango,
  gtk3,
  libv4l,
  gst_all_1,
  wayland-scanner,
  egl-wayland,
}:
let
  library-files = stdenv.mkDerivation {
    name = "nvidia-l4t-tegra-lib-files";
    version = nvidia-drivers.version;

    src = nvidia-drivers;

    nativeBuildInputs = [
      autoPatchelfHook
    ];

    buildInputs = [
      libgcc.lib
      libglvnd
      glib
      alsa-lib
      cairo
      pango
      gtk3
      libv4l
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      wayland-scanner
      egl-wayland
    ];

    installPhase = ''
      mkdir -p $out/lib
      runHook preInstall
      cp --no-preserve=mode -r usr/lib/aarch64-linux-gnu/tegra/* $out/lib/
      cp --no-preserve=mode -r usr/lib/aarch64-linux-gnu/tegra-egl/* $out/lib/
      ln -sf $out/lib/libcuda.so.1 $out/lib/libcuda.so
      ln -sf $out/lib/libcuda.so.1.1 $out/lib/libcuda.so.1
      ln -sf $out/lib/libnvbufsurface.so.1.0.0 $out/lib/libnvbufsurface.so
      ln -sf $out/lib/libnvbufsurftransform.so.1.0.0 $out/lib/libnvbufsurftransform.so
      ln -sf $out/lib/libnvbuf_utils.so.1.0.0 $out/lib/libnvbuf_utils.so
      ln -sf $out/lib/libnvdsbufferpool.so.1.0.0 $out/lib/libnvdsbufferpool.so
      ln -sf $out/lib/libnvid_mapper.so.1.0.0 $out/lib/libnvid_mapper.so
      rm $out/lib/{ld.so.conf,nvidia_icd.json,nvidia.json}
      chmod +x $out/lib/*
      runHook postInstall
    '';
  };
  nvidia-icd-json = writers.writeJSON "nvidia_icd.json" {
    file_format_version = "1.0.0";
    ICD = {
      api_version = "1.2.131";
      library_path = "${library-files}/lib/libGLX_nvidia.so.0";
    };
  };
  nvidia-json = writers.writeJSON "nvidia.json" {
    file_format_version = "1.0.0";
    ICD = {
      library_path = "${library-files}/lib/libEGL_nvidia.so.0";
    };
  };
  combined-files = runCommand "nvidia-l4t-tegra-lib-${nvidia-drivers.version}" { } ''
    mkdir -p $out/share/{glvnd/egl_vendor.d,vulkan/icd.d}
    ln -s ${library-files}/lib $out/
    ln -s ${nvidia-json} $out/share/glvnd/egl_vendor.d/nvidia.json
    ln -s ${nvidia-icd-json} $out/share/vulkan/icd.d/nvidia_icd.json
  '';
in
combined-files
