{ linuxPackagesFor
, recurseIntoAttrs
, linux_4_9-l4t
}:
let
  packages = recurseIntoAttrs (linuxPackagesFor linux_4_9-l4t);
  crossCompiledPackages = recurseIntoAttrs (linuxPackagesFor linux_4_9-l4t.cross-compiled);
in
packages // {
  cross-compiled = crossCompiledPackages;
}
