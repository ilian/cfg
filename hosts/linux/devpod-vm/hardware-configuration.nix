# The VM that create-vm.sh creates, with the partitions bootstrap/format_drive.sh creates.
{ modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  fileSystems."/" =
    { device = "/dev/mapper/cryptroot";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-partlabel/nixos-luks";

  fileSystems."/boot" =
    { device = "/dev/disk/by-partlabel/nixos-boot";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  nixpkgs.hostPlatform = "x86_64-linux";
}
