{ config, pkgs, ... }:

{

  programs.alacritty.settings.font.size = 18;

  home.packages = with pkgs; [
    # Manage docker VMs with colima
    colima
    docker
    docker-compose
  ];

  launchd.agents = {
    codeartifact-maven-updater = {
      enable = true;
      config =
        let
          homeDirectory = config.home.homeDirectory;
          tokenValiditySeconds = 12 * 60 * 60;
        in
        {
          ProgramArguments = [
            "${homeDirectory}/bin/codeartifact-maven-updater"
            "-f" # Force token generation even if token is still valid
            "-d"
            (toString tokenValiditySeconds)
          ];
          StartInterval = tokenValiditySeconds - 60;
          StandardOutPath = "${homeDirectory}/Library/Logs/codeartifact-maven-updater/out.log";
          StandardErrorPath = "${homeDirectory}/Library/Logs/codeartifact-maven-updater/err.log";
        };
    };
  };
}
