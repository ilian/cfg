 # Base module include by all hosts
 { pkgs, ... }:

 {
   time.timeZone = "Europe/Amsterdam";

   nix = {
     package = pkgs.nixVersions.stable;
     extraOptions = ''
       experimental-features = nix-command flakes
       keep-outputs = true
       keep-derivations = true
     '';
     gc = {
       automatic = true;
       dates = "03:15";
       options = "--delete-older-than 7d";
     };
   };

  nixpkgs.config.allowUnfree = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

   environment.systemPackages = with pkgs; [
     n
   ];
 }
