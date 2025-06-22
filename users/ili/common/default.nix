{ pkgs, home-manager, ... }:

{
  # TODO: Move to graphical
  fonts.packages = with pkgs; [
    nerd-fonts.hack
  ];

  home-manager.users.ili = {
    imports = [
      ./base
      ./dev
    ];
  };
}
