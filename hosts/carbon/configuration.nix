{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/avahi.nix
    ../../profiles/docker.nix
    ../../profiles/graphical.nix
    ../../profiles/hwdec-tools.nix
    ../../profiles/laptop.nix
    ../../profiles/libvirt.nix
    ../../profiles/systemd-boot.nix
    ../../profiles/waydroid.nix
    ../../profiles/idevice.nix
    ../../profiles/libvirt.nix
    ../../profiles/airplay-receiver.nix
    ../../users/ili
  ];

  # Fixes audio issues on 6.6
  # [   12.175882] sof-audio-pci-intel-tgl 0000:00:1f.3: Topology: ABI 3:22:1 Kernel ABI 3:23:0
  # [   12.176305] sof-audio-pci-intel-tgl 0000:00:1f.3: error: source BUF31.1\x10 not found
  # [   12.177141] skl_hda_dsp_generic skl_hda_dsp_generic: ASoC: topology: add_route failed: -22
  # [   12.177908] skl_hda_dsp_generic skl_hda_dsp_generic: ASoC: topology: could not load header: -22
  # [   12.178978] sof-audio-pci-intel-tgl 0000:00:1f.3: error: tplg component load failed -22
  # [   12.180788] sof-audio-pci-intel-tgl 0000:00:1f.3: error: failed to load DSP topology -22
  # [   12.181657] sof-audio-pci-intel-tgl 0000:00:1f.3: ASoC: error at snd_soc_component_probe on 0000:00:1f.3: -22
  # [   12.182507] skl_hda_dsp_generic skl_hda_dsp_generic: ASoC: failed to instantiate card -22
  # [   12.183488] skl_hda_dsp_generic: probe of skl_hda_dsp_generic failed with error -22
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  programs.nix-ld.enable = true;

  #nixpkgs.overlays = [(self: super: {
  #  mesa = pkgs.unstable.mesa;
  #})];

  networking.hostName = "carbon";

  environment.systemPackages = with pkgs; [
    steam-run
  ];

  # Cilium
  boot.kernel.sysctl = {
    # Disable rp_filter on Cilium interfaces since it may cause mangled packets to be dropped
    "net.ipv4.conf.lxc*.rp_filter" = 0;
    "net.ipv4.conf.cilium_*.rp_filter" = 0;

    # The kernel uses max(conf.all, conf.{dev}) as its value, so we need to set .all. to 0 as well.
    # Otherwise it will overrule the device specific settings.
    "net.ipv4.conf.all.rp_filter" = 0;
  };
  networking.firewall.enable = false;

  # virtualisation.virtualbox.host.enable = true;
  # environment.etc."vbox/networks.conf".text = "* 0.0.0.0/0 ::/0"; # Minikube workaround
  # users.extraGroups.vboxusers.members = [ "ili" ];


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

  services.dbus.packages = [ pkgs.gcr ];

  # https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "23.05";
}
