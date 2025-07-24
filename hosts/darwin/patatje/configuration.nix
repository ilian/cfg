{ pkgs, options, inputs, ... }:

{
  imports = [
    ../../../users/ili/darwin
  ];

  networking.computerName = "patatje";

  system.stateVersion = 5;
}
