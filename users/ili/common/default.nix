{ home-manager, ... }:

{
  home-manager.users.ili = {
    imports = [
      ./base
      ./dev
    ];
  };
}
