{
  toplevel,

  writeTextFile,
  runCommand,
  writeShellApplication,
  ubootTools,
}:
let
  boot-cmd-main = writeTextFile {
    name = "boot.cmd.post";
    text = ''
      # Set defaults env variables if they do not exist.
      setenv boot_dir ''${prefix}
      test -n ''${loader_rev}           || setenv loader_rev 0
      test -n ''${id}                   || setenv id SWR-UBU
      test -n ''${emmc}                 || setenv emmc 0
      test -n ''${rootdev}              || setenv rootdev mmcblk0p2
      test -n ''${rootfstype}           || setenv rootfstype ext4
      test -n ''${rootfs_fw}            || setenv rootfs_fw /lib/firmware/
      test -n ''${rootlabel_retries}    || setenv rootlabel_retries 1
      test -n ''${auto_rootdev_disable} || setenv auto_rootdev_disable 0
      test -n ''${fbconsole}            || setenv fbconsole 9
      test -n ''${uart_port}            || setenv uart_port 0
      test -n ''${earlycon}             || setenv earlycon 0
      test -n ''${r2p_action}           || setenv r2p_action bootloader
      test -n ''${autoboot}             || setenv autoboot 0
      test -n ''${autoboot_list}        || setenv autoboot_list 0
      test -n ''${als_enable}           || setenv als_enable 0
      test -n ''${usb3_enable}          || setenv usb3_enable 0
      test -n ''${4k60_disable}         || setenv 4k60_disable 0
      test -n ''${dvfsb}                || setenv dvfsb 0
      test -n ''${gpu_dvfsc}            || setenv gpu_dvfsc 0
      test -n ''${limit_gpu_clk}        || setenv limit_gpu_clk 0
      test -n ''${jc_rail_disable}      || setenv jc_rail_disable 0
      test -n ''${cec_disable}          || setenv cec_disable 0
      test -n ''${touch_skip_tuning}    || setenv touch_skip_tuning 0
      test -n ''${bt_ertm_disable}      || setenv bt_ertm_disable 0
      test -n ''${wifi_disable_vht80}   || setenv wifi_disable_vht80 0

      test -n ''${acc_cal_off_x}        || setenv acc_cal_off_x 0x0
      test -n ''${acc_cal_off_y}        || setenv acc_cal_off_y 0x0
      test -n ''${acc_cal_off_z}        || setenv acc_cal_off_z 0x0
      test -n ''${acc_cal_scl_x}        || setenv acc_cal_scl_x 0x0
      test -n ''${acc_cal_scl_y}        || setenv acc_cal_scl_y 0x0
      test -n ''${acc_cal_scl_z}        || setenv acc_cal_scl_z 0x0
      test -n ''${gyr_cal_off_x}        || setenv gyr_cal_off_x 0x0
      test -n ''${gyr_cal_off_y}        || setenv gyr_cal_off_y 0x0
      test -n ''${gyr_cal_off_z}        || setenv gyr_cal_off_z 0x0
      test -n ''${gyr_cal_scl_x}        || setenv gyr_cal_scl_x 0x0
      test -n ''${gyr_cal_scl_y}        || setenv gyr_cal_scl_y 0x0
      test -n ''${gyr_cal_scl_z}        || setenv gyr_cal_scl_z 0x0

      test -n ''${lite_cal_lx_lof}      || setenv lite_cal_lx_lof 0x0
      test -n ''${lite_cal_lx_cnt}      || setenv lite_cal_lx_cnt 0x0
      test -n ''${lite_cal_lx_rof}      || setenv lite_cal_lx_rof 0x0
      test -n ''${lite_cal_ly_dof}      || setenv lite_cal_ly_dof 0x0
      test -n ''${lite_cal_ly_cnt}      || setenv lite_cal_ly_cnt 0x0
      test -n ''${lite_cal_ly_uof}      || setenv lite_cal_ly_uof 0x0

      test -n ''${lite_cal_rx_lof}      || setenv lite_cal_rx_lof 0x0
      test -n ''${lite_cal_rx_cnt}      || setenv lite_cal_rx_cnt 0x0
      test -n ''${lite_cal_rx_rof}      || setenv lite_cal_rx_rof 0x0
      test -n ''${lite_cal_ry_dof}      || setenv lite_cal_ry_dof 0x0
      test -n ''${lite_cal_ry_cnt}      || setenv lite_cal_ry_cnt 0x0
      test -n ''${lite_cal_ry_uof}      || setenv lite_cal_ry_uof 0x0

      # Set logging params for each serial type.
      setenv uarta "no_console_suspend console=ttyS0,115200,8n1 loglevel=8"
      setenv uartb "no_console_suspend console=ttyS1,115200,8n1 loglevel=8"
      setenv uartc "no_console_suspend console=ttyS2,115200,8n1 loglevel=8"
      setenv usblg "usb_logging loglevel=8"
      setenv uarta_early "earlycon=uart,mmio32,0x70006000"
      setenv uartb_early "earlycon=uart,mmio32,0x70006040"
      setenv uartc_early "earlycon=uart,mmio32,0x70006200"

      # Default read addresses.
      # fdt_addr_r     0x8d000000
      # scriptaddr     0x8fe00000
      # ramdisk_addr_r 0x92000000

      # Set important addresses.
      setenv kernload 0xA0000000
      setenv initaddr 0x92000000
      setenv fdtrload 0xA8000000
      setenv fdtraddr 0x8d000000

      # Set temp addresses.
      setenv enviraddr 0x8d100000
      setenv fdtovaddr 0x8d200000


      # Set SoC info.
      if test ''${t210b01} = 1; then setenv plat_info T210B01; else setenv plat_info T210; fi

      # Set SKU info. Frig is used instead of Fric for compatibility reasons.
      if   test ''${sku} = 0; then setenv sku_info ODIN; setenv sku_rev 0
      elif test ''${sku} = 1; then setenv sku_info ODIN; setenv sku_rev b01
      elif test ''${sku} = 2; then setenv sku_info VALI; setenv sku_rev 0
      elif test ''${sku} = 3; then setenv sku_info FRIG; setenv sku_rev 0
      fi

      # Print platform info.
      echo PLAT:   ''${plat_info} SKU: ''${sku_info}
      echo Serial: ''${device_serial}
      echo BT MAC: ''${device_bt_mac}
      echo WF MAC: ''${device_wifi_mac}


      # Load Kernel.
      if load mmc ''${devnum}:''${distro_bootpart} ''${kernload} ''${boot_dir}/uImage; then echo Kernel loaded
      else echoe Kernel read failed!; echoe Rebooting in 10s..; sleep 10; reset; fi

      # Load Initramfs.
      if load mmc ''${devnum}:''${distro_bootpart} ''${initaddr} ''${boot_dir}/initramfs; then echo Initramfs loaded
      else echoe Initramfs read failed!; echoe Rebooting in 10s..; sleep 10; reset; fi

      # Load DT img.
      if load mmc ''${devnum}:''${distro_bootpart} ''${fdtrload} ''${boot_dir}/nx-plat.dtimg; then echo Device Tree Image loaded
      else echoe Device Tree Image read failed!; echoe Rebooting in 10s..; sleep 10; reset; fi


      # Get DT from image. If failed, reset.
      if dtimg load ''${fdtrload} ''${sku} ''${fdtraddr} fdtrsize; then echo Device Tree for SKU ''${sku_info} loaded
      else echoe Device Tree load for SKU ''${sku_info} failed!; echoe Rebooting in 10s..; sleep 10; reset; fi

      # Set dtb address and size from above and resize it enough to fit any change.
      fdt addr ''${fdtraddr} ''${fdtrsize}
      fdt resize 16384


      # Sanity checks for dtb info.
      if test ''${sku_info} != ''${fdt_id_text} -o ''${sku_rev} != ''${fdt_rev}; then
        echoe Device Tree loaded not correct! (SKU: ''${fdt_id_text}, Rev: ''${fdt_rev})
        echoe Expected SKU: ''${sku_info}, Rev: ''${sku_rev}
        echoe Rebooting in 10s..; sleep 10; reset
      fi


      # Patch dtb with overlays if they exist.
      if test -n ''${dtb_overlays}; then
        echo loading dtb overlays: ''${dtb_overlays}
        for ov in ''${dtb_overlays}; do
          echo Setting ''${ov}...

          # Check if DT overlay and apply it.
          if load mmc ''${devnum}:''${distro_bootpart} ''${fdtovaddr} ''${boot_dir}/overlays/''${ov}.dtbo; then
            if fdt apply ''${fdtovaddr}; then echo Successfully loaded ''${ov}.dtbo...
            else echoe Overlay ''${ov}.dtbo loading failed!; echoe Rebooting in 10s..; sleep 10; reset; fi
          fi
        done
      fi


      # Add additional bootargs for UART Logging.
      if   test ''${uart_port} = 1; then
        echoe UART-A logging enabled
        setenv bootargs_extra ''${bootargs_extra} ''${uarta}
        fdt set /serial@70006000 compatible nvidia,tegra20-uart
        fdt set /serial@70006000 status okay

        if test ''${earlycon} = 1; then
          echoe Early  logging enabled
          setenv bootargs_extra ''${bootargs_extra} ''${uarta_early}
          fdt set /serial@70006000 reset-names noreset
        fi
      elif test ''${uart_port} = 2; then
        echoe UART-B logging enabled
        setenv bootargs_extra ''${bootargs_extra} ''${uartb}
        fdt set /serial@70006040 compatible nvidia,tegra20-uart
        fdt set /serial@70006040/joyconr status disabled

        if test ''${earlycon} = 1; then
          echoe Early  logging enabled
          setenv bootargs_extra ''${bootargs_extra} ''${uartb_early}
          fdt set /serial@70006040 reset-names noreset
        fi
      elif test ''${uart_port} = 3; then
        echoe UART-C logging enabled
        setenv bootargs_extra ''${bootargs_extra} ''${uartc}
        fdt set /serial@70006200 compatible nvidia,tegra20-uart
        fdt set /serial@70006200/joyconl status disabled

        if test ''${earlycon} = 1; then
          echoe Early  logging enabled
          setenv bootargs_extra ''${bootargs_extra} ''${uartc_early}
          fdt set /serial@70006200 reset-names noreset
        fi
      fi

      # Add additional bootargs for Serial USB.
      if test ''${uart_port} = 4; then
        setenv bootargs_extra ''${usblg} ''${bootargs_extra}; echoe USB Serial logging enabled
      fi

      # Disable Joycon Rails.
      if test ''${jc_rail_disable} = 1; then
        echoe Joycon Rails disabled
        fdt set /serial@70006040 status disabled
        fdt set /serial@70006040/joyconr status disabled
        fdt set /serial@70006200 status disabled
        fdt set /serial@70006200/joyconl status disabled
      fi

      # Disable rootdev search done by initramfs.
      if test ''${auto_rootdev_disable} = 1; then
        setenv bootargs_extra ''${bootargs_extra} "auto_rootdev_disable"
      fi

      # Disable CEC auto negotiation.
      if test ''${cec_disable} = 1; then
        setenv bootargs_extra ''${bootargs_extra} "cec_disable=1"
      fi

      # Disable Touch panel tuning.
      if test ''${touch_skip_tuning} = 1; then
        setenv bootargs_extra ''${bootargs_extra} "ftm4.skip_tuning=1"
      fi

      # Disable Bluetooth ERTM.
      if test ''${bt_ertm_disable} = 1; then
        setenv bootargs_extra ''${bootargs_extra} "bluetooth.disable_ertm=1"
      fi


      # Enable eMMC.
      if test ''${emmc} = 1; then
        fdt set /sdhci@700b0600 status okay

        # Check if eMMC is initialized in 1-bit mode.
        if test "''${mmc_1bit}" = 1; then
          echoe eMMC is initialized in 1-bit mode!
          fdt set /sdhci@700b0600 bus-width <0x1>
          fdt set /sdhci@700b0600 uhs-mask <0x7F>
        fi
      fi

      # Check if SD is initialized in 1-bit mode.
      if test "''${sd_1bit}" = 1; then
        echoe SD Card is initialized in 1-bit mode!
        fdt set /sdhci@700b0000 bus-width <0x1>
        fdt set /sdhci@700b0000 uhs-mask <0x7F>
      fi

      # Check if SD DDR200 mode can be enabled.
      if test "''${loader_rev}" != 0; then
        echo SD DDR200 mode enabled
        fdt set /sdhci@700b0000 enable-ddr200
      fi

      # Enable ALS sensor.
      if test ''${als_enable} = 1; then
        echo ALS sensor enabled
        fdt set /i2c@7000c400/bh1730fvc@29 status okay
      fi

      # Disable WiFi VHT80 bonding.
      if test ''${wifi_disable_vht80} = 1; then
        echo WiFi VHT80 bonding disabled
        setenv bootargs_extra ''${bootargs_extra} "brcmfmac.vht_mask=12"
      fi

      # Set Sio calibration data.
      if test ''${sku} = 2; then
        if load mmc ''${devnum}:''${distro_bootpart} ''${enviraddr} /switchroot/switch.cal; then
          env import -t -r ''${enviraddr} ''${filesize}
          echo Sio Calibration set
          fdt set /serial@70006200/sio sio-stick-cal-l <$lite_cal_lx_lof $lite_cal_lx_cnt $lite_cal_lx_rof $lite_cal_ly_dof $lite_cal_ly_cnt $lite_cal_ly_uof>
          fdt set /serial@70006200/sio sio-stick-cal-r <$lite_cal_rx_lof $lite_cal_rx_cnt $lite_cal_rx_rof $lite_cal_ry_dof $lite_cal_ry_cnt $lite_cal_ry_uof>
          fdt set /serial@70006200/sio sio-acc-cal <$acc_cal_off_x $acc_cal_off_y $acc_cal_off_z $acc_cal_scl_x $acc_cal_scl_y $acc_cal_scl_z>
          fdt set /serial@70006200/sio sio-gyr-cal <$gyr_cal_off_x $gyr_cal_off_y $gyr_cal_off_z $gyr_cal_scl_x $gyr_cal_scl_y $gyr_cal_scl_z>
        fi
      fi

      # Get display panel handle.
      if   test ''${display_id} = f20;  then echo Display is INN 6.2; fdt get value DHANDLE /host1x/dsi/panel-i-720p-6-2 phandle
      elif test ''${display_id} = f30;  then echo Display is AUO 6.2; fdt get value DHANDLE /host1x/dsi/panel-a-720p-6-2 phandle
      elif test ''${display_id} = 10;   then echo Display is JDI 6.2; fdt get value DHANDLE /host1x/dsi/panel-j-720p-6-2 phandle
      elif test ''${display_id} = 1020; then echo Display is INN 5.5; fdt get value DHANDLE /host1x/dsi/panel-i-720p-5-5 phandle
      elif test ''${display_id} = 1030; then echo Display is AUO 5.5; fdt get value DHANDLE /host1x/dsi/panel-a-720p-5-5 phandle
      elif test ''${display_id} = 1040; then echo Display is SHP 5.5; fdt get value DHANDLE /host1x/dsi/panel-s-720p-5-5 phandle
      elif test ''${display_id} = 2050; then echo Display is SAM 7.0
      else echoe Unknown Display ID: ''${display_id}!; fi

      # Set new active display panel handle.
      if test -n ''${DHANDLE} -a ''${sku} != 3; then echo Setting Display panel; fdt set /host1x/dsi nvidia,active-panel <$DHANDLE>; fi

      # Disable USB3.
      if test ''${usb3_enable} = 0; then
        echo USB3 disabled
        fdt get value DHANDLE_USB2 /xusb_padctl@7009f000/pads/usb2/lanes/usb2-0 phandle
        fdt set /xusb@70090000 phys <$DHANDLE_USB2>
        fdt set /xusb@70090000 phy-names usb2-0
        fdt set /xudc@700d0000 phys <$DHANDLE_USB2>
        fdt set /xudc@700d0000 phy-names usb2
        fdt set /xusb_padctl@7009f000 usb3-no-mapping-war <0x1>
        fdt set /xusb_padctl@7009f000/ports/usb2-0 nvidia,usb3-port-fake <0xffffffff>
        fdt set /xusb_padctl@7009f000/ports/usb3-0 status disabled
      else
        echoe USB3 enabled
      fi

      # Disable 4 DP lanes (4K@60) on Fric.
      if test ''${sku} = 3 -a ''${4k60_disable} = 1 -a ''${usb3_enable} != 0; then
        echoe 4K60 disabled
        fdt set /i2c@7000c000/bm92t@18 rohm,dp-lanes <2>
      fi

      # Set battery voltage limit via cell age for Vali.
      if test ''${sku} = 2 -a -n "''${VLIM}"; then
        echo VALI: voltage limits [''${VLIM}, ''${SOCLIM}]
        if test "''${VLIM}" != 1070; then
          # Newer Vali. 4320 mV / 1664 mA.
          fdt set /i2c@7000c000/battery-charger@6b/charger ti,charge-voltage-limit-millivolt <0x$VLIM>
          fdt set /i2c@7000c000/battery-charger@6b/charger ti,charge-thermal-voltage-limit <0x$VLIM 0x$VLIM 0x$VLIM 0xFF0>
          fdt set /i2c@7000c000/battery-gauge@36 maxim,kernel-maximum-soc <0x$SOCLIM>
        else
          # Old Vali. 4208 mV / 1536 mA. (Unreleased?)
          fdt set /i2c@7000c000/battery-charger@6b/charger ti,charge-voltage-limit-millivolt <0x1070>
          fdt set /i2c@7000c000/battery-charger@6b/charger ti,charge-thermal-voltage-limit <0x1070 0x1070 0x1070 0xF70>
          fdt set /i2c@7000c000/battery-charger@6b/charger ti,fast-charge-current-limit-milliamp <0x600>
          fdt set /i2c@7000c000/battery-charger@6b/charger ti,charge-current-limit <0x200 0x240 0x600 0x600>
        fi
      fi

      # Enable DVFS B-Side.
      if test ''${t210b01} = 1 -a ''${dvfsb} = 1; then
        echoe DVFS B-Side enabled
        setenv bootargs_extra ''${bootargs_extra} "speedo_tegra210.sku_id=0x83 speedo_tegra210.cspd_id=2 speedo_tegra210.sspd_id=2"

        if test ''${gpu_dvfsc} != 1; then
          setenv bootargs_extra ''${bootargs_extra} "speedo_tegra210.gspd_id=2"
        fi

        if test ''${sku} = 2; then
          # 2091 MHz CPU and 844 MHz GPU hard limit. Vali.
          fdt set /cpufreq/cpu-scaling-data max-frequency <0x1FE7F8>
          fdt set /dvfs nvidia,gpu-max-freq-khz <0xCE400>
        fi
      fi

      # Enable GPU DVFS C-Side.
      if test ''${t210b01} = 1 -a ''${gpu_dvfsc} = 1; then
        echoe DVFS C-Side GPU enabled

        if test ''${dvfsb} != 1; then
          setenv bootargs_extra ''${bootargs_extra} "speedo_tegra210.sku_id=0x83 speedo_tegra210.gspd_id=3"
        else
          setenv bootargs_extra ''${bootargs_extra} "speedo_tegra210.gspd_id=3"
        fi
      fi

      # Limit GPU clock.
      if test ''${t210b01} = 1 -a ''${limit_gpu_clk} = 1; then

        if test ''${sku} != 2; then
          # If not Vali set GPU hard limit to 1075 MHz.
          echoe GPU clock limit enabled
          fdt set /dvfs nvidia,gpu-max-freq-khz <0x106800>
        fi
      fi

      # Set pmic type if special (devboard).
      if test ''${t210b01} = 1 -a -n "''${pmic_type}" -a ''${pmic_type} = 1; then
        echoe GPU 15A Regulator enabled
        fdt set /i2c@7000d000/max77812@33 reg <0x31>
        fdt set /i2c@7000d000/max77812@33/m3vout status disabled
        fdt set /i2c@7000d000/fan53528@52 status okay
        fdt set /dvfs nvidia,gpu-max-volt-mv <0x3B6>
      fi


      # Set serial number.
      if test -n ''${device_serial};   then fdt set / serial-number ''${device_serial}; fi

      # Set default bt mac. initramfs will/can change it.
      if test -n ''${device_bt_mac};   then fdt set /chosen nvidia,bluetooth-mac ''${device_bt_mac}; fi

      # Set default wifi mac. initramfs will/can change it.
      if test -n ''${device_wifi_mac}; then fdt set /chosen nvidia,wifi-mac ''${device_wifi_mac}; fi


      # Set kernel cmdline.
      # setenv bootargs ''${bootargs_extra} "root=/dev/''${rootdev} rootfstype=''${rootfstype} rw \
      # firmware_class.path=''${rootfs_fw} access=m2 \
      # rootlabel=''${id} rootlabel_retries=''${rootlabel_retries} \
      # boot_m=''${devnum} boot_p=''${distro_bootpart} swr_dir=''${boot_dir} \
      # pmc_r2p.enabled=1 pmc_r2p.action=''${r2p_action} \
      # pmc_r2p.param1=''${autoboot} pmc_r2p.param2=''${autoboot_list} \
      # fbcon=map:''${fbconsole} consoleblank=0 \
      # nvdec_enabled=0 tegra_fbmem=0x400000@0xf5a00000 "
      setenv bootargs ''${bootargs_extra} "\
        init=''${init} \
        pmc_r2p.enabled=1 pmc_r2p.action=''${r2p_action} \
        pmc_r2p.param1=''${autoboot} pmc_r2p.param2=''${autoboot_list} \
        fbcon=map:''${fbconsole} \
        tegra_fbmem=0x400000@0xf5a00000 \
        "

      # Boot kernel.
      echo Launching NixOS Kernel!
      bootm ''${kernload} ''${initaddr} ''${fdtraddr}

      echoe Failed to launch Kernel!
      echoe  
      echoe Rebooting in 10s..

      sleep 10
      reset
    '';
  };
  build-boot-cmd = writeShellApplication {
    name = "build-boot-cmd";
    text = ''
      TOPLEVEL="$1"
      echo "setenv init $TOPLEVEL/init"
      cat ${boot-cmd-main}
    '';
  };
  build-boot-scr = writeShellApplication {
    name = "build-boot-scr";
    runtimeInputs = [
      ubootTools
      build-boot-cmd
    ];
    text = ''
      TOPLEVEL="$1"
      OUT="$2"
      boot_scr="$(mktemp)"
      build-boot-cmd "$TOPLEVEL" > "$boot_scr"
      mkimage -A arm64 -C none -T script -d "$boot_scr" "$OUT"
    '';
  };
  boot-scr =
    runCommand "boot.scr"
      {
        passthru.buildScript = build-boot-scr;
      }
      ''
        ${build-boot-scr}/bin/build-boot-scr ${toplevel} $out
      '';
in
boot-scr
