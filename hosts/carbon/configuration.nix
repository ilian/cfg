{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/avahi.nix
    ../../profiles/graphical.nix
    ../../profiles/grub-efi.nix
    ../../profiles/hwdec-tools.nix
    ../../profiles/laptop.nix
    ../../profiles/libvirt.nix
    ../../profiles/obs-webcam.nix
    ../../profiles/thinkpad-battery.nix
    ../../profiles/udev.nix
    ../../users/ili
  ];

  networking.hostName = "carbon";
  virtualisation.docker.enable = true;
  services.printing.enable = true;

  services.samba = {
    enable = true;
    openFirewall = true;
    shares.guest = {
      path = "/srv/public";
      "read only" = "yes";
      "guest ok" = "yes";
      "guest only" = "yes";
    };
    extraConfig = ''
      map to guest = Bad User
      guest account = nobody
      min protocol = SMB2
    '';
  };
}
