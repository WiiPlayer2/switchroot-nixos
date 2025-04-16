{ callPackage
, runCommand
}:
{
  kernel,
  initialRamdisk,
  toplevel,
}:
let
  uImage = callPackage ./uImage.nix { inherit kernel; };
  uInitrd = callPackage ./uInitrd.nix { inherit initialRamdisk; };
  boot-scr = callPackage ./boot-scr.nix { inherit toplevel; };
  dtb-image = callPackage ./dtb-image.nix { inherit kernel; };

  package = runCommand "install-package" {} ''
    mkdir -p $out/switchroot/nixos

    cp ${uInitrd} $out/switchroot/nixos/initramfs
    cp ${uImage} $out/switchroot/nixos/uImage
    cp ${boot-scr} $out/switchroot/nixos/boot.scr
    cp ${dtb-image} $out/switchroot/nixos/nx-plat.dtimg
  '';
in
  package
