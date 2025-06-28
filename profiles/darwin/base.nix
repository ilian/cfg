# Base module include by all hosts
{ pkgs, ... }:

{
  imports = [
    ../common/base.nix
    ./dock
  ];

  nix = {
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 7d";
    };
  };

  system = {
    primaryUser = "ili";
    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        KeyRepeat = 3;  # 45 ms
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
      };

      controlcenter = {
        BatteryShowPercentage = true;
        Sound = true;  # Show icon in menu bar
        Display = true;  # Show icon in menu bar
      };

      dock = {
        show-recents = false;
        wvous-tl-corner = 2;  # Mission Control
        wvous-bl-corner = 3;  # Application Windows
        wvous-br-corner = 4;  # Desktop
      };

      finder = {
        ShowPathbar = true;
        ShowStatusBar = true;
        FXPreferredViewStyle = "Nlsv";  # List view
        FXEnableExtensionChangeWarning = false;
      };

      screencapture = {
        location = "~/Pictures/Screenshots";
      };

      trackpad = {
        Clicking = true;  # Tap to cick
      };
    };
  };
}
