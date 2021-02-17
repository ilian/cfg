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

if [ ! -d "$cfg_root/hosts/$host" ]; then
  echo "Host directory with name $host not found in $cfg_root/hosts" >&2
  exit 1
fi

rm -rf /mnt/cfg
echo "Copying NixOS configuration to /mnt/cfg" >&2
cp -r "$cfg_root" /mnt/cfg
chown -R 1000 /mnt/cfg
chgrp -R 100 /mnt/cfg
echo "Generating hardware configuration and installing to /mnt" >&2
nix-shell "/mnt/cfg/bootstrap/shell.nix" --run "\
  nixos-generate-config --root /mnt --show-hardware-config > '/mnt/cfg/hosts/$host/hardware-configuration.nix'
  nixos-install --flake '/mnt/cfg#$host' --show-trace
"
