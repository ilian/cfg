#!/usr/bin/env sh
set -e
drive="${1:-/dev/sda}"

if [ ! -b "$drive" ]; then
  echo "$drive is not a valid block device" >&2
  exit 1
fi

if [ ! -w "$drive" ]; then
  echo "Cannot write to block device $drive (running as root?)" >&2
  exit 1
fi

echo "This operation will wipe ALL data from $drive" >&2
read -p "Are you sure? [y/N] " choice
case "$choice" in
  y|Y ) ;;
  n|N|"" )
    echo "Aborted" >&2
    exit 1
  ;;
  * )
    echo "Invalid choice" >&2
    exit 1
  ;;
esac

echo "Unmounting drives" >&2
for part in "$drive"?*; do
  umount "$part" || true
done

echo "Unmounting encrypted drives" >&2
for luks_part in "$(dmsetup ls --target crypt | cut -f1)"; do
  umount "/dev/mapper/$luks_part" || true
  cryptsetup luksClose "/dev/mapper/$luks_part" || true
done

sgdisk -Z "$drive"
sgdisk -n 0:0:+512MiB -t 0:ef00 -c 0:nixos-boot "$drive"
mkfs.fat -F 32 "${drive}1"

while [ -z $luks ]; do
  read -p "Enable disk encryption with LUKS? [Y/n] " choice
  case "$choice" in
    y|Y|"" )
      luks=1
    ;;
    n|N )
      luks=0
    ;;
    * )
      echo "Invalid choice" >&2
    ;;
  esac
done

if [ $luks -eq 1 ]; then
  sgdisk -n 0:0:0 -t 0:8309 -c 0:nixos-LUKS "$drive"
  cryptsetup luksFormat "${drive}2"
  cryptsetup luksOpen "${drive}2" cryptroot
  mkfs.ext4 /dev/mapper/cryptroot
else
  sgdisk -n 0:0:0 -t 0:8300 -c 0:nixos-root "$drive"
  mkfs.ext4 "${drive}2"
fi

echo "Mounting partitions to /mnt and /mnt/boot" >&2
if [ $luks -eq 1 ]; then
  mount /dev/mapper/cryptroot /mnt
else
  mount "${drive}2" /mnt
fi

mkdir /mnt/boot
mount "${drive}1" /mnt/boot
