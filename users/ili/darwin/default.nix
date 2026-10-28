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

    # Reduce the spacing between menu bar icons. System items (Wi-Fi, battery,
    # Control Center, ...) are drawn by ControlCenter, which only honors the
    # ByHost global domain.
    targets.darwin.currentHostDefaults.NSGlobalDomain = {
      NSStatusItemSpacing = 2;
      NSStatusItemSelectionPadding = 2;
    };

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
