{ pkgs }:

pkgs.writeShellScriptBin "n" ''
  name=$(basename "$0")
  cmd=$1; shift
  cfg=/cfg

  help() {
    echo "$name is a simple nix flakes helper" >&2
    echo "Usage: $name subcommand" >&2
    echo "Where subcommmand is one of the following:" >&2
    echo "• r - Run a program from nixpkgs" >&2
    echo "• s[earch] - Search packages in the nixpkgs flake" >&2
    echo "• sh[ell] - Enter a shell with the specified packages (from nixpkgs when no flake specified)" >&2
    echo "• sw[itch] - Rebuild and switch to the NixOS configuration of the current host" >&2
    echo "• vm - Build a VM of the NixOS configuration of the current host" >&2
  }

  resolve_package() {
    if [[ "$1" == *#* ]]; then
      echo "$1"
    else
      echo "nixpkgs#$1"
    fi
  }

  if [[ "$cmd" == s || "$cmd" == search ]]; then
    nix search nixpkgs "$@"
  elif [[ "$cmd" == r || "$cmd" == run ]]; then
    package="$(resolve_package "$1")"
    shift
    nix run "$package" "$@"
  elif [[ "$cmd" == "sh" || "$cmd" == shell ]]; then
    packages=()
    while [[ $# -gt 0 && "$1" != -* ]]; do
      packages+=("$(resolve_package "$1")")
      shift
    done
    nix shell "''${packages[@]}" "$@"
  elif [[ "$cmd" == sw || "$cmd" == switch ]]; then
    nixos-rebuild switch --flake "$cfg" "$@"
  elif [[ "$cmd" == vm ]]; then
    nixos-rebuild build-vm --flake "$cfg" "$@"
  else
    help
  fi
''
