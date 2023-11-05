{ config, pkgs, ... }:

{
  # Manage Neovim config manually with Lazy.nvim
  # Symlink outside nix store to allow lazy-lock.json
  home.file."./.config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/src/ilian/cfg/users/ili/dev/vim/config";
  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
    # Compilers for treesitter, mason, ...
    # TODO: supply to Mason outside $PATH to avoid conflicts with existing
    #       packages in $PATH
    extraPackages = with pkgs; [
      stdenv
      gnumake
      gcc
      nodejs
      go
    ];
  };
}
