{ pkgs, home-manager, ... }:

{
  users.users.ili = {
    name = "ili";
    createHome = true;
    home = "/Users/ili";
    isHidden = false;
    shell = pkgs.bash;
  };
}
