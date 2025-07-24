{ pkgs, options, inputs, ... }:

{
  imports = [
    ../../../users/ili/darwin
  ];

  networking.computerName = "patatje";
  networking.localHostName = "patatje";

  system.stateVersion = 5;
}
