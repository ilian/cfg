{ pkgs, ... }:
{
  imports = [
    ./vim
  ];

  home.packages = with pkgs; [
    gh # GitHub cli
    unstable.cloudflared # Expose local HTTP endpoint publicly

    # nixpkgs
    nix-review
    nix-prefetch-git
    nix-prefetch-github

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
        d = "diff";
        fo = "fetch origin";
        fu = "fetch upstream";
        rom = "rebase origin/master";
        rum = "rebase upstream/master";
        s = "status";
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
