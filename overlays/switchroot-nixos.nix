inputs:
final: prev:
let
  callPackage' = prev.lib.callPackageWith (final // { inherit inputs; });
in
prev.lib.packagesFromDirectoryRecursive {
  callPackage = callPackage';
  directory = ../pkgs/by-name;
}

