{ pkgs, options, inputs, ... }:

{
  imports = [
    ../../../users/ili/darwin
  ];

  networking.computerName = "patatje";
  networking.localHostName = "patatje";
  networking.hostName = "patatje";

  system.stateVersion = 5;
}
