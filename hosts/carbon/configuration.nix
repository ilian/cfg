{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/avahi.nix
    ../../profiles/graphical.nix
    ../../profiles/systemd-boot.nix
    ../../profiles/hwdec-tools.nix
    ../../profiles/laptop.nix
    ../../profiles/libvirt.nix
    ../../profiles/idevice.nix
    ../../profiles/docker.nix
    ../../users/ili
  ];

  # Using the latest kernel version fixed some audio issues I had on 5.15
  #boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "carbon";

  # Ignore EC interrupts that cause low-latency audio issues
  # https://gist.github.com/ilian/439be7f83db31d58ce448eeb9ed34323
  # TODO: After switching from KDE to Cinnamon, the issue appears to be resolved!
  #boot.kernelParams = [ "acpi_mask_gpe=0x6e" ];

  # Disable power-profiles-daemon, which is enabled in KDE module by default
  # This conflicts with TLP enabled below
  # services.power-profiles-daemon.enable = false;

  # services.tlp = {
  #   enable = true;
  #   # settings = {
  #   #   # Improve battery lifespan
  #   #   START_CHARGE_THRESH_BAT0 = 75;
  #   #   STOP_CHARGE_THRESH_BAT0 = 80;
  #   # };
  # };

  services.printing.enable = true;
  services.flatpak.enable = true;

  # https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "23.05";
}
