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
        uid = 510;
      };
    };
  };
}
