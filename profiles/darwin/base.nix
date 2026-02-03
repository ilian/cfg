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

  networking.applicationFirewall = {
    enable = true;
    blockAllIncoming = false;
    allowSigned = false;
    allowSignedApp = false;
    enableStealthMode = true;
  };

  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;  # Required for Touch ID support for sudo to work with tmux
  };

  services.openssh.extraConfig = ''
    # Require public key authentication method
    PasswordAuthentication no
    ChallengeResponseAuthentication no
    KbdInteractiveAuthentication no
    PubkeyAuthentication no
  '';

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
        orientation = "right";
        tilesize = 40;
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

  launchd.daemons.refresh-ls = {
    environment = {
      PATH = "/usr/bin:/bin:/Applications/Little Snitch.app/Contents/Components";
    };
    script = ''
      set -eu
      littlesnitch write-preference networkFilterEnabled false
      littlesnitch write-preference networkFilterEnabled true
      killall "Little Snitch Agent"
    '';

    # serviceConfig = {
    #   Label         = "com.user.refresh-ls";
    #   KeepAlive = {
    #     SuccessfulExit = false;
    #   };
    #   StartInterval = 3 * 60 * 60 - 60;
    #   StartCalendarInterval = [
    #     { Hour =  3; Minute = 0; }         # 03:00
    #     { Hour =  6; Minute = 0; }         # 06:00
    #     { Hour =  9; Minute = 0; }         # 09:00
    #     { Hour = 12; Minute = 0; }         # 12:00
    #     { Hour = 15; Minute = 0; }         # 15:00
    #     { Hour = 18; Minute = 0; }         # 18:00
    #     { Hour = 21; Minute = 0; }         # 21:00
    #     { Hour =  0; Minute = 0; }         # 00:00
    #   ];
    # };
  };
}
