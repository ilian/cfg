{ pkgs, ... }:
{
  imports = [
    ./ideavim.nix
    ./helix.nix
  ];

  home.packages = with pkgs; [
    gh # GitHub cli
    tig # ncurses-based interface for git
    unstable.tuicr # Terminal UI for code review
    unstable.herdr
    python3Packages.grip # Preview Markdown files in a browser
    cloudflared # Expose web server publicly with cloudflared tunnel
    devbox
    foreman  # Procfile runner for development
    hey  # HTTP load test
    pre-commit
    presenterm

    # Infra
    awscli2
    terraform
    kubectl
    krew
    kubernetes-helm
    kubetail
    kubeval
    kubectx
    k9s
    dive # Examine contents of OCI images
    cilium-cli

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
    mitmproxy
    mitmproxy2swagger

    # Hardware
    nxpmicro-mfgtools # uuu
    #pmbootstrap

    # Analytics
    sqlite
    duckdb

    android-tools
    scrcpy
  ];

  programs = {
    bash = {
      shellAliases = {
        "k" = "kubectl";
        "tf" = "terraform";
        "lg" = "lazygit";
      };
      initExtra = ''
        complete -o nospace -C ${pkgs.terraform}/bin/terraform terraform
        complete -o nospace -C ${pkgs.terraform}/bin/terraform tf
        complete -F _complete_alias k
      '';
    };
    readline = {
      enable = true;
      extraConfig = ''
        # Enable colors when autocompleting file paths in a shell session
        set colored-stats on
      '';
    };
    lazygit = {
      enable = true;
      enableBashIntegration = false;  # Exit (q) changes directory to repo root otherwise
    };
    fzf = {
      enable = true;
      enableBashIntegration = true;
    };
  };

}
