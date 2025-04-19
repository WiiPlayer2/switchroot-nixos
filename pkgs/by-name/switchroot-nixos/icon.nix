{ pkgs
, inputs
, runCommand
, imagemagick
}:
let
  # icons = (import inputs.nixos-artwork { inherit pkgs; }).icons;
  base-svg = "${inputs.nixos-artwork}/logo/nix-snowflake-rainbow.svg";
  icon-bmp = runCommand "icon.bmp" {} ''
    ${imagemagick}/bin/magick \
      ${base-svg} -channel rgba -alpha on -resize 192x192 \
      BMP3:$out
  '';
in
  icon-bmp
