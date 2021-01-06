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
read -p "Are you sure? [y/n] " choice
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

for part in "$drive"?*; do
  umount "$part" || true
done

sgdisk -Z "$drive"
sgdisk -n 0:0:+512MiB -t 0:ef00 -c 0:main-boot "$drive"
sgdisk -n 0:0:0 -t 0:8300 -c 0:main-nixos "$drive"

mkfs.fat -F 32 "${drive}1"
yes | mkfs.ext4 "${drive}2"

echo "Mounting partitions to /mnt and /mnt/boot" >&2
mount "${drive}2" /mnt
mkdir /mnt/boot
mount "${drive}1" /mnt/boot

