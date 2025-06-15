{ config, lib, ...} :

with lib;

{
  users.users.ili = {
    createHome = true;
    isNormalUser = true;
    extraGroups = [
     "wheel"
     "audio"
     "dialout" # Full access to serial ports
    ] ++ optionals config.networking.networkmanager.enable [ "networkmanager" ]
      ++ optionals config.virtualisation.docker.enable [ "docker" ]
      ++ optionals config.virtualisation.podman.enable [ "podman" ]
      ++ optionals config.virtualisation.libvirtd.enable [ "libvirtd" ]
      ++ optionals config.services.jack.jackd.enable [ "jackaudio" ]
      ++ optionals config.hardware.i2c.enable [ "i2c" ];
    openssh.authorizedKeys.keyFiles =
      mapAttrsToList (name: _: ./ssh-keys + "/${name}")
                     (builtins.readDir ./ssh-keys);
  };

  home-manager.users.ili = {
    imports = [
      ./base
      ./dev
    ] ++ optionals (
      config.services.xserver.enable ||
      config.services.displayManager.sddm.wayland.enable
    ) [ ./graphical ];
  };

  # Don't require a password to login if disk encryption is enabled
  services.displayManager.autoLogin = mkIf (config.boot.initrd.luks.devices != {}) {
    enable = true;
    user = "ili";
  };
}
