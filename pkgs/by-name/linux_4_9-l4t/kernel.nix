{ sources
, callPackage
, inputs
, buildLinux
, fetchurl
, lib

, ...
} @ args:
buildLinux (args // rec {
  version = "4.9.140-l4t";
  modDirVersion = version;
  src = "${sources.combined-src}/kernel";
  # src = sources.combined-src;
  # sourceRoot = "${sources.combined-src.name}/kernel";
  defconfig = "tegra_linux_defconfig";
  enableCommonConfig = false;
  extraMakeFlags = [
    # "-j1"
    # "--debug=v,i"
    # "--print-data-base"
    # "tegra-dtstree=\"./nvidia\""
    # "KCFLAGS=-Wno-error=unused-label"
    # "KCFLAGS=-Wno-error=unused-variable"
    # "--keep-going"
  ];
  structuredExtraConfig = with lib.kernel; {
    SND_SOC_TEGRA = no;
    SND_SOC_TEGRA_T210REF_ALT = no;
    SND_SOC_TEGRA_T210REF_P2382_ALT = no;
    AHCI_TEGRA = no;
    BT_HCIVHCI = no;
    BLK_DEV_PCIESSD_MTIP32XX = no;
    BLK_DEV_DRBD = no;
    CRYPTO_LRW = no;
    BT_HCIBPA10X = no;
    BT_HCIBFUSB = no;
    BT_MTKUART = no;
    BT_MRVL = no;
    BT_HCIUART_NOKIA = no;
    HMM_DMIRROR = no;
    CPU_IDLE_TEGRA19X = no;
    I2C_TEGRA194_SLAVE = no;
    DRM_TEGRA = no;
    EXTCON_ADC_JACK = no;
    BATTERY_BQ27441 = no;
    INV_ICM42600_I2C = no;
    DRM_NOUVEAU = no;
    RTC_DRV_RX6110 = no;
    TEGRA_HOST1X = no;
    MTTCAN_IVC = no;
    REGULATOR_TPS61280 = no;
    # SCSI_UFS_DWC_TC_PCI = no;
    SCSI_UFSHCD = no;
    # SCSI_UFSHCD_PCI = no;
    PWM_TEGRA_DFLL = no;
    NVI_MPU_IIO = no;
    NVI_MPU_INPUT = no;
    NVI_MPU_RELAY = no;
    NVS_BMI160_IIO = no;
    NVS_BMI160_INPUT = no;
    NVS_BMI160_RELAY = no;
    NVS = no;
    TEGRA_BOOTLOADER_BOOT_CFG = no;
    # PCIE_DW = no;
    # PCIE_DW_HOST = no;
    PCIE_TEGRA = no;
    # PCIE_TEGRA_HOST = no;
    EVENTLIB = no;
    QCOM_SPMI_IADC = no;
    QCOM_SPMI_VADC = no;
    QCOM_SPMI_TEMP_ALARM = no;
    # NVS_DFSH = no;
    # NVS_IIO = no;
    # NVI_AK89XX = no;
    # NVI_BMPX80 = no;
    # NVS_AIS328DQ = no;
    # NVS_A3G4250D = no;
    # NVS_BH1730FVC = no;
    # NVS_CM3217 = no;
    # NVS_CM3218 = no;
    # NVS_ISL2902X = no;
    # NVS_JSA1127 = no;
    # NVS_LTR659 = no;
    # NVS_MAX4400X = no;
    # NVS_VEML6030 = no;
    # NVS_IQS2X3 = no;
    NVS_LED_TEST = no;
    MTTCAN = no;

    # TEGRA_GRHOST = no; # NOTE: xxd tool needed to convert .json -> .h
    # TEGRA_GK20A = no; # TODO: some kind of implicit function declaration for some reason
    # GK20A_PCI = no; # TODO: some kind of implicit function declaration for some reason
  };
  kernelPatches = [
    {
      name = "01-unify_l4t_sources.patch";
      patch = fetchurl {
        url = "https://raw.githubusercontent.com/libretro/Lakka-LibreELEC/refs/heads/devel/projects/L4T/devices/Switch/patches/l4t-kernel-sources/01-unify_l4t_sources.patch";
        hash = "sha256-RQPFgWWeDJNceKYGJ7bu/ElIyIU1uf2hf3KkUzTsjLE=";
      };
    }
    {
      name = "02-set_kcflags.patch";
      patch = ./patches/02-set_kcflags.patch;
    }
    {
      name = "03-add_dtbs_install_target.patch";
      patch = ./patches/03-add_dtbs_install_target.patch;
    }
  ];
  # KCFLAGS = [
  #   "-march=armv8-a+simd+crypto+crc"
  #   "-mtune=cortex-a57"
  #   "--param=l1-cache-line-size=64"
  #   "--param=l1-cache-size=32"
  #   "--param=l2-cache-size=2048"
  #   # "-Wno-error=maybe-uninitialized"
  #   # "-Wno-error=stringop-truncation"
  #   # "-Wno-error=address"
  #   # "-Wno-error=array-bounds=1"
  #   # "-Wno-error=stringop-overread"
  #   "-Wno-error=unused-variable"
  # ];
} // (args.argsOverride or {}))
