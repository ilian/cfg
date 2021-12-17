{ nixos-hardware, ... } :
{
  system = "x86_64-linux";
  modules = [
    nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
    ./configuration.nix
  ];
}
