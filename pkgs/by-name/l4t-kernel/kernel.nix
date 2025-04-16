{ sources

# kernel lambda args
, features ? {}
, kernelPatches ? []
, randstructSeed ? ""

# dependencies
, lib
, stdenv
, runCommand

, bc
, perl
, gzip
}:
with lib;
let
  readConfig =
    configfile:
    import
      (runCommand "config.nix" { } ''
        echo "{" > "$out"
        while IFS='=' read key val; do
          [ "x''${key#CONFIG_}" != "x$key" ] || continue
          no_firstquote="''${val#\"}";
          echo '  "'"$key"'" = "'"''${no_firstquote%\"}"'";' >> "$out"
        done < "${configfile}"
        echo "}" >> $out
      '').outPath;

  configfile = stdenv.mkDerivation {
    name = "l4t-kernel-config";

    src = sources.combined-src;

    configurePhase = ''
    '';

    buildPhase = ''
      cd kernel
      make tegra_linux_defconfig

      echo "CONFIG_DMIID=y" >> .config
      echo "CONFIG_AUTOFS_FS=y" >> .config
    '';

    installPhase = ''
      cp .config $out
    '';
  };

  buildResult = stdenv.mkDerivation {
    name = "l4t-kernel-output";

    src = sources.combined-src;

    nativeBuildInputs = [
      bc
      perl
    ];

    enableParallelBuilding = true;

    KCFLAGS = [
      "-march=armv8-a+simd+crypto+crc"
      "-mtune=cortex-a57"
      "--param=l1-cache-line-size=64"
      "--param=l1-cache-size=32"
      "--param=l2-cache-size=2048"
      "-Wno-error=maybe-uninitialized"
      "-Wno-error=stringop-truncation"
      "-Wno-error=address-of-packed-member"
      "-Wno-error=address"
      "-Wno-error=array-bounds=1"
      "-Wno-error=stringop-overread"
    ];

    configurePhase = ''
      mkdir build
      export buildRoot="$(pwd)/build"

      ln -sv ${configfile} kernel/.config

      cd kernel
      make prepare
      make modules_prepare
    '';

    buildPhase = ''
      make -j$NIX_BUILD_CORES tegra-dtstree="../hardware/nvidia"
    '';

    installPhase = ''
      mkdir -p $out/dtbs
      make zinstall INSTALL_PATH=$out
      make modules_install INSTALL_MOD_PATH=$out
      make firmware_install INSTALL_MOD_PATH=$out INSTALL_FW_PATH=$out/lib/firmware

      cp arch/arm64/boot/dts/tegra210*.dtb $out/dtbs/
    '';
  };

  config = readConfig "${configfile}";
in
runCommand "l4t-kernel" {
  passthru = {
    version = "4.19";
    modDirVersion = "4.9.140-l4t";
    config =
      let
        attrName = attr: "CONFIG_" + attr;
        config' = {
          isSet = attr: hasAttr (attrName attr) config';

          getValue = attr: if config'.isSet attr then getAttr (attrName attr) config' else null;

          isYes = attr: (config'.getValue attr) == "y";

          isNo = attr: (config'.getValue attr) == "n";

          isModule = attr: (config'.getValue attr) == "m";

          isEnabled = attr: (config'.isModule attr) || (config'.isYes attr);

          isDisabled = attr: (!(config'.isSet attr)) || (config'.isNo attr);
        } // config;
      in
        config';
  };
} ''
  cd ${buildResult}
  mkdir -p $out
  cp -r lib $out/
  cp System.map-4.9.140-l4t $out/System.map
  cp vmlinuz-4.9.140-l4t $out/Image.gz
  ${gzip}/bin/gzip -cd $out/Image.gz > $out/Image
  cp -r dtbs $out/
''
