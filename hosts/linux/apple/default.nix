{ nixos-hardware, ... } :
{
  system = "x86_64-linux";
  modules = [
    nixos-hardware.nixosModules.apple-macbook-air-3
    ./configuration.nix
  ];
}
