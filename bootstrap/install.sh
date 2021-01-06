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

cfg_root="$(dirname "$0")/.."

rm -rf /mnt/cfg
cp -r "$cfg_root" /mnt/cfg
nix-shell "/mnt/cfg/bootstrap/shell.nix" --run "nixos-install --flake /mnt/cfg#$host --show-trace"
