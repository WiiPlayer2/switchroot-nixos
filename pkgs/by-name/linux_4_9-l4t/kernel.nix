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
  
  enableCommonConfig = false;
  defconfig = "tegra_linux_defconfig";
  structuredExtraConfig = with lib.kernel; {
    AHCI_TEGRA = no;
    BATTERY_BQ27441 = no;
    BLK_DEV_DRBD = no;
    BLK_DEV_PCIESSD_MTIP32XX = no;
    BT_HCIBFUSB = no;
    BT_HCIBPA10X = no;
    BT_HCIUART_NOKIA = no;
    BT_HCIVHCI = no;
    BT_MRVL = no;
    BT_MTKUART = no;
    CPU_IDLE_TEGRA19X = no;
    CRYPTO_LRW = no;
    DRM_NOUVEAU = no;
    DRM_TEGRA = no;
    EVENTLIB = no;
    EXTCON_ADC_JACK = no;
    HMM_DMIRROR = no;
    I2C_TEGRA194_SLAVE = no;
    INV_ICM42600_I2C = no;
    MTTCAN = no;
    MTTCAN_IVC = no;
    NVI_MPU_IIO = no;
    NVI_MPU_INPUT = no;
    NVI_MPU_RELAY = no;
    NVS = no;
    NVS_BMI160_IIO = no;
    NVS_BMI160_INPUT = no;
    NVS_BMI160_RELAY = no;
    NVS_LED_TEST = no;
    PCIE_TEGRA = no;
    PWM_TEGRA_DFLL = no;
    QCOM_SPMI_IADC = no;
    QCOM_SPMI_TEMP_ALARM = no;
    QCOM_SPMI_VADC = no;
    REGULATOR_TPS61280 = no;
    RTC_DRV_RX6110 = no;
    SCSI_UFSHCD = no;
    SND_SOC_TEGRA = no;
    SND_SOC_TEGRA_T210REF_ALT = no;
    SND_SOC_TEGRA_T210REF_P2382_ALT = no;
    TEGRA_BOOTLOADER_BOOT_CFG = no;
    TEGRA_HOST1X = no;

    SND_SOC_TEGRA210_IQC_ALT = yes;
    # SND_SOC_TEGRA210_ADSP_ALT = no;
    SND_SOC_TEGRA_T186REF_ALT = no;
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
} // (args.argsOverride or {}))
