{ pkgs }:

let
  contents = builtins.readFile ./n.sh;
in
  pkgs.writeShellScriptBin "n" contents
