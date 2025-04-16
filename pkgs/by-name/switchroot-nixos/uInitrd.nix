{ initialRamdisk
, ubootTools
, runCommand
}:
runCommand "uInitrd" {} ''
  initrdFile="${initialRamdisk}/initrd"
  ${ubootTools}/bin/mkimage -A arm64 -T ramdisk -C gzip -n "NixOS initrd" -d $initrdFile $out
''
