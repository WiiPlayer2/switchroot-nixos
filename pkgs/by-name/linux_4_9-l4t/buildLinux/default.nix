{ buildPackages
, callPackage
, perl
, bison ? null
, flex ? null
, gmp ? null
, libmpc ? null
, mpfr ? null
, pahole
, lib
, stdenv
, nixosTests
, inputs
} @ deps:
{ # The kernel source tarball.
  src

, # The kernel version.
  version

, # Allows overriding the default defconfig
  defconfig ? null

, # Legacy overrides to the intermediate kernel config, as string
  extraConfig ? ""

  # Additional make flags passed to kbuild
, extraMakeFlags ? []

, # enables the options in ./common-config.nix; if `false` then only
  # `structuredExtraConfig` is used
 enableCommonConfig ? true

, # kernel intermediate config overrides, as a set
 structuredExtraConfig ? {}

, # The version number used for the module directory
  # If unspecified, this is determined automatically from the version.
  modDirVersion ? null

, # An attribute set whose attributes express the availability of
  # certain features in this kernel.  E.g. `{iwlwifi = true;}'
  # indicates a kernel that provides Intel wireless support.  Used in
  # NixOS to implement kernel-specific behaviour.
  features ? {}

, # Custom seed used for CONFIG_GCC_PLUGIN_RANDSTRUCT if enabled. This is
  # automatically extended with extra per-version and per-config values.
  randstructSeed ? ""

, # A list of patches to apply to the kernel.  Each element of this list
  # should be an attribute set {name, patch} where `name' is a
  # symbolic name and `patch' is the actual patch.  The patch may
  # optionally be compressed with gzip or bzip2.
  kernelPatches ? []
, ignoreConfigErrors ? stdenv.hostPlatform.linux-kernel.name != "pc"
, extraMeta ? {}

, isZen      ? false
, isLibre    ? false
, isHardened ? false

# easy overrides to stdenv.hostPlatform.linux-kernel members
, autoModules ? stdenv.hostPlatform.linux-kernel.autoModules
, preferBuiltin ? stdenv.hostPlatform.linux-kernel.preferBuiltin or false
, kernelArch ? stdenv.hostPlatform.linuxArch
, kernelTests ? []
, ...
} @ args:
import ./generic.nix (deps // args)
