# Base module include by all hosts
{ pkgs, ... }:

{
  imports = [
    ../common/base.nix
  ];
}
