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
      ./dev
    ];
  };

  local.dock.enable = true;
  local.dock.entries = [
    { path = "${pkgs.unstable.alacritty}/Applications/Alacritty.app/"; }
    { path = "/Applications/Firefox.app/"; }
    { path = "${pkgs.unstable.slack}/Applications/Slack.app/"; }
    { path = "${pkgs.unstable.thunderbird}/Applications/Thunderbird.app/"; }
    { path = "${pkgs.unstable.obsidian}/Applications/Obsidian.app/"; }
    { path = "/System/Applications/TextEdit.app"; }
    { path = "/System/Applications/Utilities/Activity Monitor.app"; }
    { path = "/System/Applications/System Settings.app"; }
    {
      path = "~/Downloads/";
      section = "others";
    }
    {
      path = "~/Pictures/";
      section = "others";
    }
  ];
}
