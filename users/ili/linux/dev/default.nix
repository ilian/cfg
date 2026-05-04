{ pkgs, ... }:
{
  home.packages = with pkgs; [
    d-spy # D-Bus explorer
  ];
}
