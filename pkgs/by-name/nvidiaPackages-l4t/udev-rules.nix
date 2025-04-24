{ config
, runCommand
}:
runCommand "nvidia-l4t-udev-rules" {} ''
  mkdir -p $out/etc/udev/rules.d
  cp ${config}/etc/udev/rules.d/99-tegra-devices.rules $out/etc/udev/rules.d/
  sed '/\/usr\/sbin\/camera_device_detect/d' -i $out/etc/udev/rules.d/99-tegra-devices.rules
''
