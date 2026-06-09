inputs: final: prev:
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
  pinnedPkgs = inputs.nixpkgs-pinned.legacyPackages.${prev.stdenv.hostPlatform.system};

  systemdOverride =
    {
      pkgFn,
      withLogind,
      withNspawn,
    }:
    let
      pinnedPkg = pkgFn pinnedPkgs;
      prevPkg = pkgFn prev;
    in
    pinnedPkg.overrideAttrs (finalAttrs: prevAttrs: {
      passthru = prevAttrs.passthru // {
        inherit withLogind withNspawn;
      };
    });
in
prev.lib.packagesFromDirectoryRecursive {
  callPackage = callPackage';
  directory = ../pkgs/by-name;
}
// {
  # alsa-lib = prev.alsa-lib.overrideAttrs (prev': {
  #   pname = "${prev'.pname}-with-tegra";
  #   postInstall = ''
  #     ${prev'.postInstall}
  #     ln -s ${final.nvidiaPackages-l4t.alsa-config}/share/alsa/cards/* $out/share/alsa/cards/
  #     ln -s ${final.nvidiaPackages-l4t.alsa-config}/share/alsa/init $out/share/alsa/
  #   '';
  # });
  pipewire-with-tegra = prev.pipewire.override { inherit alsa-lib; };

  systemd = systemdOverride {
    pkgFn = x: x.systemd;
    withLogind = true;
    withNspawn = true;
  };
  systemdMinimal = systemdOverride {
    pkgFn = x: x.systemdMinimal;
    withLogind = false;
    withNspawn = false;
  };
  systemdLibs = systemdOverride {
    pkgFn = x: x.systemdLibs;
    withLogind = false;
    withNspawn = false;
  };
  systemdUkify = systemdOverride {
    pkgFn = x: x.systemdUkify;
    withLogind = true;
    withNspawn = true;
  };
}
