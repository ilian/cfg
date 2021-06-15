{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils/flatten-tree-system";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager/95da56b783e4ccc8ded71137e4add780b239dd46";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    musnix = {
      url = "github:musnix/musnix";
      flake = false;
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    nix-elixir = {
      url = "github:hauleth/nix-elixir";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, home-manager, ... }:
  with builtins;
  with nixpkgs.lib;
  let
    inherit (flake-utils.lib) eachDefaultSystem flattenTreeSystem;
    allowUnfreeModule = { nixpkgs.config.allowUnfree = true; };
    inputFlakes = {
      nix.registry = {
        nixpkgs.flake = nixpkgs;
        home-manager.flake = home-manager;
      };
    };
    overlayModule = {
      nixpkgs.overlays = [
        self.overlay
        inputs.neovim-nightly-overlay.overlay
        (import inputs.nix-elixir)
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
