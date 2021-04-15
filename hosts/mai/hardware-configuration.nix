{ modulesPath, ... }:
{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # Taken from /proc/cmdline of Ubuntu 20.04.2 LTS on OCI
  boot.kernelParams = [
    "console=tty1"
    "console=ttyS0"
    "nvme.shutdown_timeout=10"
    "libiscsi.debug_libiscsi_eh=1"
    "crash_kexec_post_notifiers"
  ];

  boot.growPartition = true;
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    autoResize = true;
  };
}

