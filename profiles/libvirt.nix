{ pkgs, ... }:

{
  # Avoid having to manually connect in virt-manager
  environment.sessionVariables.LIBVIRT_DEFAULT_URI = [ "qemu:///system" ];

  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf.enable = true; # UEFI
    qemu.ovmf.package = pkgs.OVMFFull; # Use UEFI image with Secure Boot support
    qemu.swtpm.enable = true;
  };

  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [ virt-manager ];
}
