# Use shell-nix to use nix command with flakes support
# This is useful when bootstrapping from a NixOS install image

let
  nixpkgs = builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-20.09.tar.gz;
  pkgs = import nixpkgs { };
  installPkgs = (import "${nixpkgs}/nixos" {
    configuration = {};
    system = pkgs.system;
  }).config.system.build;
in

pkgs.stdenvNoCC.mkDerivation {
  name = "flakes-bootstrap";
  nativeBuildInputs = with installPkgs; [
    pkgs.nixFlakes

    # Override potentially old versions of install image
    nixos-generate-config
    nixos-install
    nixos-enter
    nixos-rebuild
    # manual.manpages
  ];

  shellHook = ''
    # Work around error of nixos-rebuild: unrecognised flag '--experimental-features'
    # Let nixos-rebuild use the nix package we define
    export _NIXOS_REBUILD_REEXEC=1

    nix() {
      ${pkgs.nixFlakes}/bin/nix --option experimental-features "nix-command flakes" "$@"
    }
  '';
}
