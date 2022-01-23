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
    ../../profiles/idevice.nix
    ../../profiles/podman.nix
    ../../users/ili
  ];

  networking.hostName = "carbon";

  # Ignore EC interrupts that cause low-latency audio issues
  # https://gist.github.com/ilian/439be7f83db31d58ce448eeb9ed34323
  boot.kernelParams = [ "acpi_mask_gpe=0x6e" ];

  services.tlp = {
    enable = true;
    settings = {
      # Improve battery lifespan
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

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
