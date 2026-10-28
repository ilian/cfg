{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils/flatten-tree-system";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    musnix = {
      url = "github:musnix/musnix";
      flake = false;
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, flake-utils, home-manager, darwin, deploy-rs, ... }:
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
        self.overlays.default
        #(self: super: { unstable = nixpkgs-unstable.legacyPackages.${self.system}; })
        (final: prev: { unstable = import nixpkgs-unstable { system = final.stdenv.hostPlatform.system; config.allowUnfree = true; }; })
      ];
    };
    commonModules = [
      inputFlakes
      overlayModule
    ];
    linuxModules = [
      ./profiles/linux/base.nix
      (import inputs.musnix)
      home-manager.nixosModules.home-manager
    ];
    darwinModules = [
      ./profiles/darwin/base.nix
      home-manager.darwinModules.home-manager
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

        # Deployed with `deploy`, building on the hosts as macOS can't build for Linux
        deploy.nodes = genAttrs [ "maja" "baguette" "ampere" ] (host:
          let
            cfg = self.nixosConfigurations.${host};
            # Activate with the deploy-rs of nixpkgs, which is in the binary
            # cache and matches the `deploy` CLI
            deployPkgs = cfg.pkgs.appendOverlays [
              deploy-rs.overlays.default
              (final: prev: { deploy-rs = { inherit (cfg.pkgs) deploy-rs; inherit (prev.deploy-rs) lib; }; })
            ];
          in {
            hostname = host;
            sshUser = "ili";
            user = "root";
            remoteBuild = true;
            profiles.system.path = deployPkgs.deploy-rs.lib.activate.nixos cfg;
          });

        # Export packages defined in ./pkgs as an overlay and flake packages.
        overlays.default = import ./pkgs;
      };
  in
  (eachDefaultSystem
    (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
          { packages = (flattenTreeSystem system (outputs.overlays.default pkgs pkgs)); }
  )) // outputs;
}
