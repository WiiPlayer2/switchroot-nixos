{
  pkgs,
  inputs,
  runCommand,
  imagemagick,
  resvg,
}:
let
  # icons = (import inputs.nixos-artwork { inherit pkgs; }).icons;
  base-svg = "${inputs.nixos-artwork}/logo/nix-snowflake-rainbow.svg";
  icon-bmp = runCommand "icon.bmp" {
    buildInputs = [
      imagemagick
      resvg
    ];
  } ''
    resvg --width 192 --height 192 ${base-svg} icon.png
    magick icon.png $out
  '';
in
icon-bmp
