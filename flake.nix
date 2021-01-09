{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:rycee/home-manager";
      follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils/flatten-tree-system";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }: 
  with builtins;
  with nixpkgs.lib;
  let
    inherit (flake-utils.lib) eachDefaultSystem flattenTreeSystem;
    allowUnfreeModule = { nixpkgs.config.allowUnfree = true; };
    nixWithFlakes = ( { pkgs, ... } : {
      nix = {
        package = pkgs.nixFlakes;
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
      };
    });
    inputFlakes = {
      nix.registry = with inputs; {
        nixpkgs.flake = nixpkgs;
        home-manager.flake = home-manager;
      };
    };
    addFlakeOverlay = {
      nixpkgs.overlays = [ self.overlay ];
    };
    defaultModules = [
      ./profiles/base.nix
      allowUnfreeModule
      nixWithFlakes
      inputFlakes
      addFlakeOverlay
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
