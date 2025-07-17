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
      triggerScript = pkgs.writeShellScript "codeartifact-trigger" ''
        set -eu
        out_path="$HOME/.m2/settings.xml"
        if [[ -f "$out_path" ]]; then
          last_mod=$(stat -f %m "$out_path")
          now=$(date +%s)
          if (( now - last_mod < ${toString (tokenValiditySeconds - 60)} )); then
            exit 0
          fi
        fi
        exec $HOME/bin/codeartifact-maven-updater -f -d ${toString tokenValiditySeconds}
      '';
    in
    {
      enable = true;
      config = {
        ProgramArguments = [ (toString triggerScript) ];
        StartInterval = 10;
        StandardOutPath = "${homeDirectory}/Library/Logs/codeartifact-maven-updater/out.log";
        StandardErrorPath = "${homeDirectory}/Library/Logs/codeartifact-maven-updater/err.log";
      };
    };
}
