{ pkgs, ... }:
{
  imports = [
    ./vim
    ./ideavim.nix
    ./helix.nix
  ];

  home.packages = with pkgs; [
    gh # GitHub cli
    python3Packages.grip # Preview Markdown files in a browser
    cloudflared # Expose web server publicly with cloudflared tunnel
    devbox
    foreman  # Procfile runner for development
    hey  # HTTP load test

    # Infra
    awscli2
    terraform
    kubectl
    kubernetes-helm
    kubetail
    kubeval
    kubectx
    k9s
    minikube
    dive # Examine contents of OCI images
    trivy # Scan OCI images for vulnerabilities

    # Scripts
    checkbashisms
    shellcheck

    # nixpkgs
    nixpkgs-review
    nix-prefetch-git
    nix-prefetch-github

    # Debugging
    gdb
    radare2
    xxd

    # Hardware
    nxpmicro-mfgtools # uuu
    #pmbootstrap

    # Analytics
    sqlite
    clickhouse
    duckdb
  ];

  programs = {
    bash = {
      shellAliases = {
        "k" = "kubectl";
        "g" = "git";
        "tf" = "terraform";
        "e" = "$EDITOR";
        "lg" = "lazygit";
      };
      initExtra = ''
        complete -o nospace -C ${pkgs.terraform}/bin/terraform terraform
        complete -o nospace -C ${pkgs.terraform}/bin/terraform tf
        . ${pkgs.complete-alias}/bin/complete_alias
        complete -F _complete_alias k
        complete -F _complete_alias g
      '';
    };
    git = {
      enable = true;
      lfs.enable = true;
      aliases = {
        c = "commit";
        co = "checkout";
        d = "diff";
        ds = "diff --staged";
        fo = "fetch origin";
        fp = "fetch -p";
        fu = "fetch upstream";
        l = "log";
        rom = "rebase origin/master";
        rum = "rebase upstream/master";
        s = "status";
      };
      ignores = [
        "*.swp"
        "*.kate-swp"
        ".direnv"
        ".venv"
        ".idea"
        ".DS_Store"
      ];
      userName = "ilian";
      userEmail = "ilian@tuta.io";
      includes = [
        { path = "~/work/.gitconfig"; condition = "gitdir:~/work/"; }
      ];
      extraConfig = {
        merge.conflictstyle = "diff3";
      };
    };
    lazygit = {
      enable = true;
    };
    fzf = {
      enable = true;
      enableBashIntegration = true;
    };
    vscode = {
      enable = true;
    };
  };

}
