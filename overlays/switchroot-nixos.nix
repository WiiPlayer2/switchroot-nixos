inputs:
final: prev:
let
  callPackage' = prev.lib.callPackageWith (final // { inherit inputs; });
  alsa-lib = prev.alsa-lib.overrideAttrs (prev': {
    pname = "${prev'.pname}-with-tegra";
    postInstall = ''
      ${prev'.postInstall}
      ln -s ${final.nvidiaPackages-l4t.alsa-config}/share/alsa/cards/* $out/share/alsa/cards/
      ln -s ${final.nvidiaPackages-l4t.alsa-config}/share/alsa/init $out/share/alsa/
    '';
  });
in
prev.lib.packagesFromDirectoryRecursive {
  callPackage = callPackage';
  directory = ../pkgs/by-name;
} // {
  # alsa-lib = prev.alsa-lib.overrideAttrs (prev': {
  #   pname = "${prev'.pname}-with-tegra";
  #   postInstall = ''
  #     ${prev'.postInstall}
  #     ln -s ${final.nvidiaPackages-l4t.alsa-config}/share/alsa/cards/* $out/share/alsa/cards/
  #     ln -s ${final.nvidiaPackages-l4t.alsa-config}/share/alsa/init $out/share/alsa/
  #   '';
  # });
  pipewire-with-tegra = prev.pipewire.override { inherit alsa-lib; };
}

