{ pkgs, ... }:
{

  programs.alacritty.settings.font.size = 18;

  home.packages = with pkgs; [
    # Manage docker VMs with colima
    colima
    docker
    docker-compose
  ];
}
