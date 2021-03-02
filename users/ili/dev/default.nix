{ pkgs, ... }:
{
  imports = [
    ./vim
  ];

  home.packages = with pkgs; [
    # Debugging
    gdb
    radare2
    xxd
  ];

  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      aliases = {
        co = "checkout";
        fu = "fetch upstream";
      };
      ignores = [ "*.swp" ];
      userName = "ilian";
      userEmail = "ilian@tuta.io";
    };
    fzf = {
      enable = true;
      enableBashIntegration = true;
    };
  };

}
