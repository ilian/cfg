# Set battery tresholds on new ThinkPad models not supported by tp_smapi
#
# Optimizing battery for lifespan (years) instead of runtime (hours):
# sudo tpacpi-bat -s start 0 85 # Start charging when charge <= 85%
# sudo tpacpi-bat -s stop 0 90 # Stop charging when charge >= 90%
#
# To restore to defaults:
# sudo tpacpi-bat -s start 0 0
# sudo tpacpi-bat -s stop 0 0
#
# Get current state:
# sudo tpacpi-bat -g start 1
# sudo tpacpi-bat -g stop 1

{ pkgs, config, ... }:

{
  environment.systemPackages = [ pkgs.tpacpi-bat ];
  boot.extraModulePackages = [ config.boot.kernelPackages.acpi_call ];
}
