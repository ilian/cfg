{ pkgs, ... }:
{
  imports = [
    ./vim
  ];

  home.packages = with pkgs; [
    file
    binutils # readelf
    ripgrep
    ranger

    # Archiving
    unzip
    (p7zip.override {
      enableUnfree = true; # RAR support
    })

    # System monitoring
    htop
    nload
    cpufrequtils # cpufreq-info
    pciutils # lspci
    arp-scan

    # Debugging
    gdb
    radare2
  ];

  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      aliases = {
        co = "checkout";
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
