{
  kernel,
  ubootTools,
  gzip,
  runCommand,
}:
let
  image-gz = runCommand "Image.gz" { } ''
    ${gzip}/bin/gzip -c ${kernel}/Image > $out
  '';
  uimage = runCommand "uImage" { } ''
    ${ubootTools}/bin/mkimage -A arm64 -a 0x80200000 -e 0x80200000 -n "NixOS kernel" -d ${image-gz} $out
  '';
in
uimage
