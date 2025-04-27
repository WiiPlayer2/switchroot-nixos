{
  kernel,
  runCommand,
  android-tools,
}:
runCommand "nx-plat.dtimg" { } ''
  ${android-tools}/bin/mkdtboimg create $out --page_size=1000 \
    ${kernel}/dtbs/tegra210-odin.dtb --id=0x4F44494E \
    ${kernel}/dtbs/tegra210b01-odin.dtb --id=0x4F44494E --rev=0xb01 \
    ${kernel}/dtbs/tegra210b01-vali.dtb --id=0x56414C49 \
    ${kernel}/dtbs/tegra210b01-fric.dtb --id=0x46524947
''
