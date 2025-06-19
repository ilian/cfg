{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils/flatten-tree-system";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    musnix = {
      url = "github:musnix/musnix";
      flake = false;
    };

    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, flake-utils, home-manager, darwin, ... }:
  with builtins;
  with nixpkgs.lib;
  let
    inherit (flake-utils.lib) eachDefaultSystem flattenTreeSystem;
    inputFlakes = {
      nix.registry = {
        nixpkgs.flake = nixpkgs;
        home-manager.flake = home-manager;
      };
    };
    overlayModule = {
      nixpkgs.overlays = [
        self.overlay
        #(self: super: { unstable = nixpkgs-unstable.legacyPackages.${self.system}; })
        (final: prev: { unstable = import nixpkgs-unstable { system = final.system; config.allowUnfree = true; }; })
      ];
    };
    commonModules = [
      ./profiles/common/base.nix
      inputFlakes
      overlayModule
      home-manager.nixosModules.home-manager
    ];
    linuxModules = [
      ./profiles/linux/base.nix
      (import inputs.musnix)
    ];
    darwinModules = [
      ./profiles/darwin/base.nix
    ];
    outputs =
      {
        # Import host configurations from ./hosts/
        nixosConfigurations =
          genAttrs (attrNames (filterAttrs (name: type: type == "directory") (readDir ./hosts/linux)))
                   (host: nixpkgs.lib.nixosSystem (
                     let
                       syscfg = (import (./hosts/linux + "/${host}") inputs);
                       defaultModules = commonModules ++ linuxModules;
                     in syscfg // { modules = syscfg.modules ++ defaultModules; }
                   ));

        darwinConfigurations =
          genAttrs (attrNames (filterAttrs (name: type: type == "directory") (readDir ./hosts/darwin)))
                   (host: darwin.lib.darwinSystem (
                     let
                       syscfg = (import (./hosts/darwin + "/${host}") inputs);
                       defaultModules = commonModules ++ darwinModules;
                     in syscfg // { modules = syscfg.modules ++ defaultModules; }
                   ));

        # Export packages defined in ./pkgs as overlay and flake packages
        overlay = import ./pkgs;
      };
  in
  (eachDefaultSystem
    (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
          { packages = (flattenTreeSystem system (outputs.overlay pkgs pkgs)); }
  )) // outputs;
}
