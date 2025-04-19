{ callPackage
, runCommand
, writeShellApplication
, closureInfo

, rsync
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

  closure-info = closureInfo {
    rootPaths = [ toplevel ];
  };

  copy-closure = writeShellApplication {
    name = "copy-closure-to";
    runtimeInputs = [
      rsync
    ];
    text = ''
      TARGET="$1"
      # shellcheck disable=SC2046
      sudo rsync -auh --info=progress2 $(cat ${closure-info}/store-paths) "$TARGET/nix/store"
      sudo cp ${closure-info}/registration "$TARGET/copy-closure-registration"
      sudo nixos-enter --root "$TARGET" --command "nix-store --load-db /copy-closure-registration"
      sudo rm "$TARGET/copy-closure-registration"
    '';
  };

  package = runCommand "switchroot-boot" {} ''
    mkdir -p $out/misc
    ln -s ${closure-info} $out/misc/closure-info
    ln -s ${copy-closure}/bin/copy-closure-to $out/misc/

    mkdir -p $out/switchroot/nixos

    cp ${uInitrd} $out/switchroot/nixos/initramfs
    cp ${uImage} $out/switchroot/nixos/uImage
    cp ${boot-scr} $out/switchroot/nixos/boot.scr
    cp ${dtb-image} $out/switchroot/nixos/nx-plat.dtimg
  '';
in
  package
