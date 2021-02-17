{ config, lib, ...} :

with lib;

{
  users.users.ili = {
    createHome = true;
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" ]
      ++ optionals config.networking.networkmanager.enable [ "networkmanager" ]
      ++ optionals config.virtualisation.docker.enable [ "docker" ]
      ++ optionals config.services.jack.jackd.enable [ "jackaudio" ];
  };

  home-manager.users.ili = {
    imports = [
      ./base
      ./dev
    ];
  };

  # Don't require a password to login if disk encryption is enabled
  services.xserver.displayManager.autoLogin = lib.mkIf (config.boot.initrd.luks.devices != {}) {
    enable = true;
    user = "ili";
  };
}
