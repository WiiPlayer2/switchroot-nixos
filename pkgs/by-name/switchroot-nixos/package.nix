{ callPackage }:
{
  kernel,
  initialRamdisk,
  toplevel,
}:
let
  uImage = callPackage ./uImage.nix { inherit kernel; };
in
  uImage
