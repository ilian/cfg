# The drives as install.sh lays them out. The system is on an md RAID0 of both
# NVMe drives, with the ESP in front of it on the first one. The HDDs each hold
# a LUKS volume, which the ZFS pool tank mirrors. All LUKS volumes share one
# passphrase, which systemd caches, so the initrd asks for it once.
{ ... }:

{
  boot.swraid = {
    enable = true;
    mdadmConf = ''
      # mdmonitor only runs for redundant arrays, this silences the warning about the missing alert command
      PROGRAM /run/current-system/sw/bin/true
    '';
  };

  boot.initrd.luks.devices = {
    cryptroot = {
      device = "/dev/md/root";
      # For the fstrim timer
      allowDiscards = true;
    };
    hdd0.device = "/dev/disk/by-partlabel/hdd0";
    hdd1.device = "/dev/disk/by-partlabel/hdd1";
  };

  fileSystems."/" = {
    device = "/dev/mapper/cryptroot";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/nixos-boot";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  boot.supportedFilesystems.zfs = true;
  boot.zfs = {
    extraPools = [ "tank" ];
    # Names the vdevs after their LUKS volumes
    pools.tank.devNodes = "/dev/mapper";
    forceImportRoot = false;
  };
  networking.hostId = "31ce5d25";
  services.zfs.autoScrub.enable = true;

  # Logs failing attributes and self-tests, a short self-test daily and a long one weekly
  services.smartd = {
    enable = true;
    defaults.autodetected = "-a -o on -S on -s (S/../.././02|L/../../6/03)";
  };
}
