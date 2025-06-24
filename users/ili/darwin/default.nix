{ pkgs, ... }:

{
  imports = [
    ../common
  ];

  # Users are expected to be created in System Preferences and assigned admin group
  users = {
    knownUsers = [ "ili" ];
    users = {
      ili = {
        name = "ili";
        createHome = true;
        home = "/Users/ili";
        isHidden = false;
        shell = pkgs.bashInteractive;
        uid = 501;
      };
    };
  };

  home-manager.users.ili = {
    imports = [
      ../common/graphical
    ];
  };

  local.dock.enable = true;
  local.dock.entries = [
    { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
    { path = "/System/Applications/System Settings.app"; }
    {
      path = "/Users/ili/Downloads/";
      section = "others";
    }
  ];
  # defaults to config.system.primaryUser
  local.dock.username = "ili";
}
