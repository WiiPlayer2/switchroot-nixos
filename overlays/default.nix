inputs:
rec {
  switchroot-nixos = import ./switchroot-nixos.nix inputs;
  default = switchroot-nixos;
}
