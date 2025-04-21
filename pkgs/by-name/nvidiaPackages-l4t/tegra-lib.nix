{ nvidia-drivers
, runCommand
, stdenv
, autoPatchelfHook
, libgcc
, libglvnd
, glib
, alsa-lib
, cairo
, pango
, gtk3
, libv4l
, gst_all_1
, wayland-scanner
, egl-wayland
}:
# runCommand "nvidia-l4t-tegra-lib" {} ''
#   mkdir -p $out/lib
#   cp --no-preserve=mode -r ${nvidia-drivers}/usr/lib/aarch64-linux-gnu/tegra/* $out/lib/
# ''
stdenv.mkDerivation {
  name = "nvidia-l4t-tegra-lib";
  version = "32.6.1";

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
    ln -s $out/lib/libcuda.so.1.1 $out/lib/libcuda.so.1
    runHook postInstall
  '';
}
