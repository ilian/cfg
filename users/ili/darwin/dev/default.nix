{ pkgs, ... }:
{

  home.packages = with pkgs; [
    # Manage docker VMs with colima
    colima
    docker
    docker-compose
  ];
}
