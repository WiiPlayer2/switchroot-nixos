{ callPackage
, runCommand
, writeShellApplication
, closureInfo
, inputs

, rsync
, openssh
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
  icon = callPackage ./icon.nix { inherit inputs; };

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
      sudo rsync -au --info=progress2 $(cat ${closure-info}/store-paths) "$TARGET/nix/store"
      sudo cp ${closure-info}/registration "$TARGET/copy-closure-registration"
      sudo nixos-enter --root "$TARGET" --command "nix-store --load-db /copy-closure-registration"
      sudo rm "$TARGET/copy-closure-registration"
    '';
  };

  copy-via-ssh = writeShellApplication {
    name = "copy-via-ssh";
    runtimeInputs = [
      openssh
    ];
    text = ''
      TARGET="$1"
      nix-copy-closure --to "$TARGET" ${toplevel}
      scp ${switchroot-boot}/* "$TARGET:/boot/switchroot/nixos/"
    '';
  };

  switchroot-boot = runCommand "switchroot-boot" {
    passthru = {
      inherit icon uInitrd uImage boot-scr dtb-image;
    };
  } ''
    mkdir -p $out

    cp ${icon} $out/icon.bmp
    cp ${uInitrd} $out/initramfs
    cp ${uImage} $out/uImage
    cp ${boot-scr} $out/boot.scr
    cp ${dtb-image} $out/nx-plat.dtimg
  '';

  package = runCommand "switchroot-pkg" {
    passthru.boot = switchroot-boot;
  } ''
    mkdir -p $out/{misc,switchroot}
    ln -s ${closure-info} $out/misc/closure-info
    ln -s ${copy-closure}/bin/copy-closure-to $out/misc/
    ln -s ${copy-via-ssh}/bin/copy-via-ssh $out/misc/
    ln -s ${switchroot-boot} $out/switchroot/nixos
  '';
in
  package
