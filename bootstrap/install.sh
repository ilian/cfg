#!/usr/bin/env sh
set -e
host=$1

if [ -z "$host" ]; then
  echo "No host specified" >&2
  exit 1
fi

if [ ! -w "/mnt" ]; then
  echo "Unable to write to /mnt (are we root?)" >&2
  exit 1
fi

cfg_root="$(realpath "$(dirname "$0")/..")"

host_dir="hosts/linux/$host"

if [ ! -d "$cfg_root/$host_dir" ]; then
  echo "Host directory with name $host not found in $cfg_root/hosts/linux" >&2
  exit 1
fi

rm -rf /mnt/cfg
echo "Copying NixOS configuration to /mnt/cfg" >&2
cp -r "$cfg_root" /mnt/cfg
chown -R 1000 /mnt/cfg
chgrp -R 100 /mnt/cfg
rm -rf /mnt/cfg/.git # Use generated files not added to git
echo "Generating hardware configuration and installing to /mnt" >&2
nixos-generate-config --root /mnt --show-hardware-config > "/mnt/cfg/$host_dir/hardware-configuration.nix"
nixos-install --flake "/mnt/cfg#$host" --impure --show-trace
