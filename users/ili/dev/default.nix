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

    cloudflared # Expose local HTTP endpoint publicly
  ];

  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      aliases = {
        co = "checkout";
        fo = "fetch origin";
        fu = "fetch upstream";
        rom = "rebase origin/master";
        rum = "rebase upstream/master";
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
