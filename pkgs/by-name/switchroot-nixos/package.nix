{ callPackage }:
{
  kernel,
  initialRamdisk,
  toplevel,
}:
let
  uImage = callPackage ./uImage.nix { inherit kernel; };
  uInitrd = callPackage ./uInitrd.nix { inherit initialRamdisk; };
  boot-scr = callPackage ./boot-scr.nix { inherit toplevel; };
in
  boot-scr
