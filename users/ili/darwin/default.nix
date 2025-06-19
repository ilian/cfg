{ pkgs, home-manager, ... }:

{
  imports = [
    ../common
  ];

  users.users.ili = {
    name = "ili";
    createHome = true;
    home = "/Users/ili";
    isHidden = false;
    shell = pkgs.bash;
  };
}
