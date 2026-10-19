{ config, lib, pkgs, ... }:

{
  options.ili.dev.enable = lib.mkEnableOption "development tools for ili" // { default = true; };

  config = {
    # TODO: Move to graphical
    fonts.packages = with pkgs; [
      nerd-fonts.hack
    ];

    home-manager.users.ili = {
      imports = [
        ./base
      ] ++ lib.optionals config.ili.dev.enable [ ./dev ];
    };
  };
}
