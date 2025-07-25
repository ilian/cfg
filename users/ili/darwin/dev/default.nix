{ config, pkgs, ... }:

{

  programs.alacritty.settings.font.size = 18;

  home.packages = with pkgs; [
    # Manage docker VMs with colima
    colima
    docker
    docker-compose
  ];

  launchd.agents.codeartifact-maven-updater =
    let
      homeDirectory = config.home.homeDirectory;
      tokenValiditySeconds = 12 * 60 * 60;
      tokenValidityMarginSeconds = 60;
    in
    {
      enable = true;
      config = {
        ProgramArguments = [
          "${homeDirectory}/bin/codeartifact-maven-updater"
          "-f" # Force token generation even if token is still valid
          "-d"
          (toString tokenValiditySeconds)
        ];
        # Run job every N seconds, but will be missed completely during sleep
        StartInterval = tokenValiditySeconds - tokenValidityMarginSeconds;
        # Run at 00:00 and 12:00 every day, launchd will start the job next time
        # it is woken up. This option is independent of StartInterval.
        StartCalendarInterval = [
          {
            Hour = 0;
            Minute = 0;
          }
          {
            Hour = 12;
            Minute = 0;
          }
        ];
        # Retry once every 10 seconds if the program fails
        KeepAlive = {
          SuccessfulExit = false;
        };

        StandardOutPath = "${homeDirectory}/Library/Logs/codeartifact-maven-updater/out.log";
        StandardErrorPath = "${homeDirectory}/Library/Logs/codeartifact-maven-updater/err.log";
      };
    };
}
