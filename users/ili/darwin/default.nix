{ config, lib, pkgs, ... }:

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
    ] ++ lib.optionals config.ili.dev.enable [ ./dev ];

    programs.bash.shellAliases.tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";

    programs.ghostty = {
      enable = true;
      package = null; # Installed outside of Nix
      settings = {
        font-family = "Hack Nerd Font Mono";
        theme = "light:Selenized Light,dark:Kanagawa Wave";
        keybind = [
          "alt+left=unbind"
          "alt+right=unbind"
        ];
      };
    };
  };
}
