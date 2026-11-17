#!/usr/bin/env nix
#! nix shell nixpkgs#tailscale nixpkgs#gptfdisk nixpkgs#mdadm nixpkgs#cryptsetup nixpkgs#dosfstools --command bash
# Run it as root in a NixOS installer with ZFS, booted with UEFI, from a checkout of this repository:
#   hosts/linux/croissant/install.sh
# It wipes the four drives and lays them out as storage.nix describes, with one passphrase for all
# LUKS volumes. It asks to log in croissant's two Tailscale nodes: the system's, and the initrd's for
# unlocking, croissant-initrd. Then it installs croissant.
set -euo pipefail
shopt -s nullglob

nvme0=/dev/disk/by-id/nvme-INTEL_SSDPE2MX450G7_CVPF641600EC450RGN
nvme1=/dev/disk/by-id/nvme-INTEL_SSDPE2MX450G7_CVPF6472006A450RGN
hdd0=/dev/disk/by-id/ata-HGST_HUS726040ALA610_K4G2D13B
hdd1=/dev/disk/by-id/ata-HGST_HUS726040ALA610_N8GNY4GY
cfg=$(realpath "$(dirname "$0")/../../..")

if [ "$(id -u)" != 0 ]; then
  echo "Run this as root" >&2
  exit 1
fi
if [ ! -d /sys/firmware/efi ]; then
  echo "Not booted with UEFI" >&2
  exit 1
fi
# The installer's own, as it has to match its kernel module
if ! command -v zpool > /dev/null; then
  echo "The installer lacks ZFS" >&2
  exit 1
fi

echo "This wipes ALL data on:" >&2
printf '  %s\n' "$nvme0" "$nvme1" "$hdd0" "$hdd1" >&2
read -rp "Are you sure? [y/N] " choice
case "$choice" in
  y|Y ) ;;
  * )
    echo "Aborted" >&2
    exit 1
  ;;
esac

IFS= read -rsp "Passphrase of the LUKS volumes: " pass
echo >&2
IFS= read -rsp "Repeat it: " repeat
echo >&2
if [ -z "$pass" ] || [ "$pass" != "$repeat" ]; then
  echo "The passphrase is empty or differs from its repetition" >&2
  exit 1
fi

echo "Releasing what a previous run left on the drives" >&2
if mountpoint -q /mnt; then umount -R /mnt; fi
if zpool list tank > /dev/null 2>&1; then zpool export tank; fi
for name in cryptroot hdd0 hdd1; do
  if [ -e "/dev/mapper/$name" ]; then cryptsetup close "$name"; fi
done
if grep -qs '^md' /proc/mdstat; then mdadm --stop --scan; fi
for drive in "$nvme0" "$nvme1" "$hdd0" "$hdd1"; do
  # Otherwise udev assembles the previous array again as soon as the partitions reappear
  for part in "$drive"-part*; do wipefs -aq "$part"; done
  sgdisk -Z "$drive" > /dev/null
done

echo "Partitioning" >&2
# Ending on 4KiB boundaries, for the 4KiB sectors of LUKS
sgdisk -I -n 1:0:+1GiB -t 1:ef00 -c 1:nixos-boot -n 2:0:0 -t 2:fd00 -c 2:root0 "$nvme0" > /dev/null
sgdisk -I -n 1:0:0 -t 1:fd00 -c 1:root1 "$nvme1" > /dev/null
sgdisk -I -n 1:0:0 -t 1:8309 -c 1:hdd0 "$hdd0" > /dev/null
sgdisk -I -n 1:0:0 -t 1:8309 -c 1:hdd1 "$hdd1" > /dev/null
udevadm settle

echo "Creating the RAID0 of the NVMe drives" >&2
# On the homehost any, the array is local to every host, so whatever its hostname, the initrd
# assembles it as /dev/md/root. The installer's udev may lack mdadm's rules for those names.
mdadm --create /dev/md0 --run --level=0 --raid-devices=2 --metadata=1.2 \
  --homehost=any --name=root "$nvme0-part2" "$nvme1-part1"
udevadm settle

echo "Encrypting" >&2
luks() {
  printf %s "$pass" | cryptsetup luksFormat --batch-mode --sector-size 4096 --key-file - "$1"
  printf %s "$pass" | cryptsetup open --key-file - "$1" "$2"
}
luks /dev/md0 cryptroot
luks "$hdd0-part1" hdd0
luks "$hdd1-part1" hdd1

echo "Creating the file systems" >&2
mkfs.ext4 -q /dev/mapper/cryptroot
mkfs.fat -F 32 /dev/disk/by-partlabel/nixos-boot > /dev/null
zpool create -o ashift=12 -O compression=lz4 -O atime=off -O xattr=sa -O acltype=posixacl \
  -O dnodesize=auto tank mirror /dev/mapper/hdd0 /dev/mapper/hdd1
# croissant's hostid differs from the installer's, it only imports exported pools without force
zpool export tank

mkdir -p /mnt
mount /dev/mapper/cryptroot /mnt
mkdir /mnt/boot
mount -o fmask=0077,dmask=0077 /dev/disk/by-partlabel/nixos-boot /mnt/boot

# The initrd's secrets, which remote-unlock.nix and remote-unlock-tailscale.nix describe
mkdir -p /mnt/etc/secrets/initrd/tailscale
ssh-keygen -q -t ed25519 -N "" -f /mnt/etc/secrets/initrd/ssh_host_ed25519_key

# Log in a Tailscale node with a tailscaled on its state
login() {
  tailscaled --tun=userspace-networking --port=0 --no-logs-no-support --statedir="$1" --socket="/run/$2.sock" > /dev/null 2>&1 &
  until [ -S "/run/$2.sock" ]; do
    kill -0 $!
    sleep 1
  done
  echo "Log in $2:" >&2
  tailscale --socket="/run/$2.sock" up --hostname="$2"
  kill $!
  wait $! || true
}
login /mnt/etc/secrets/initrd/tailscale croissant-initrd
login /mnt/var/lib/tailscale croissant

echo "Installing croissant" >&2
nixos-install --flake "$cfg#croissant" --no-channel-copy

fingerprint=$(ssh-keygen -lf /mnt/etc/secrets/initrd/ssh_host_ed25519_key.pub)
umount -R /mnt
cat >&2 <<EOF
croissant is installed. Reboot, then unlock its drives with one of:
  ssh -p 2222 root@croissant-initrd    # on your tailnet
  ssh -p 2222 root@<its public IP>
The initrd's host key is $fingerprint
Then disable the key expiry of croissant-initrd in Tailscale's admin console: the initrd can't renew its key.
EOF
