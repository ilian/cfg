{ pkgs, options, inputs, ... }:

{
  imports = [
    ../../../users/ili/darwin
  ];

  system.stateVersion = 5;
}
