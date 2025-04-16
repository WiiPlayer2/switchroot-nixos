{ kernel
, ubootTools
, runCommand
}:
runCommand "uImage" {} ''
  ${ubootTools}/bin/mkimage -A arm64 -a 0x80200000 -e 0x80200000 -n "NixOS kernel" -d ${kernel}/Image.gz $out
''
