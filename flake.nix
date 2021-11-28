{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils/flatten-tree-system";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    musnix = {
      url = "github:musnix/musnix";
      flake = false;
    };

    nix-elixir = {
      url = "github:hauleth/nix-elixir";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, flake-utils, home-manager, ... }:
  with builtins;
  with nixpkgs.lib;
  let
    inherit (flake-utils.lib) eachDefaultSystem flattenTreeSystem;
    allowUnfreeModule = {
      nixpkgs.config.allowUnfree = true;
    };
    inputFlakes = {
      nix.registry = {
        nixpkgs.flake = nixpkgs;
        home-manager.flake = home-manager;
      };
    };
    overlayModule = {
      nixpkgs.overlays = [
        self.overlay
        (import inputs.nix-elixir)
        #(self: super: { unstable = nixpkgs-unstable.legacyPackages.${self.system}; })
        (final: prev: { unstable = import nixpkgs-unstable { system = final.system; config.allowUnfree = true; }; })
      ];
    };
    defaultModules = [
      ./profiles/base.nix
      allowUnfreeModule
      inputFlakes
      overlayModule
      (import inputs.musnix)
      home-manager.nixosModules.home-manager
    ];
    outputs =
      {
        # Import host configurations from ./hosts/
        nixosConfigurations =
          genAttrs (attrNames (filterAttrs (name: type: type == "directory") (readDir ./hosts)))
                   (host: nixpkgs.lib.nixosSystem (
                     let syscfg = (import (./hosts + "/${host}") inputs);
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
