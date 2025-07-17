# Base module include by all darwin hosts

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

  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;  # Required for Touch ID support for sudo to work with tmux
  };

  system = {
    primaryUser = "ili";
    defaults = {
      NSGlobalDomain = {
        AppleShowAllFiles = true;  # Show hidden files
        AppleShowAllExtensions = true;
        KeyRepeat = 2;  # 30 ms
        # Repeat a key when holding it down which is important for graphical
        # editors with vim emulation such as the Jetbrains IDEs
        ApplePressAndHoldEnabled = false;
        # Disable add period with double-space
        NSAutomaticPeriodSubstitutionEnabled = false;
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
        location = "~/Pictures";  # Directory is not auto-created
      };

      trackpad = {
        Clicking = true;  # Tap to cick
      };
    };
  };
}
