{ pkgs, ... }:
{
  imports = [
    ./vim
    ./ideavim.nix
  ];

  home.packages = with pkgs; [
    gh # GitHub cli
    unstable.cloudflared # Expose local HTTP endpoint publicly

    # Scripts
    checkbashisms
    shellcheck

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
        c = "commit";
        co = "checkout";
        d = "diff";
        fo = "fetch origin";
        fp = "fetch -p";
        fu = "fetch upstream";
        l = "log";
        rom = "rebase origin/master";
        rum = "rebase upstream/master";
        s = "status";
      };
      ignores = [ "*.swp" ];
      userName = "ilian";
      userEmail = "ilian@tuta.io";
      includes = [
        { path = "~/work/.gitconfig"; condition = "gitdir:~/work/"; }
      ];
    };
    fzf = {
      enable = true;
      enableBashIntegration = true;
    };
  };

}
