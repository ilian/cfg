{ config, pkgs, ... }:

{
  home.sessionVariables.EDITOR = "nvim";

  # Manage Neovim config manually with Lazy.nvim
  # Symlink outside nix store to allow lazy-lock.json
  home.file."./.config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/src/ilian/cfg/users/ili/common/dev/vim/config";
  programs.neovim = {
    enable = true;
    package = pkgs.unstable.neovim-unwrapped;
    # Keep Home Manager's generated bootstrap Lua in the wrapper so it does
    # not collide with the imperatively managed ~/.config/nvim/init.lua.
    sideloadInitLua = true;
    vimAlias = true;
    vimdiffAlias = true;
    # Preserve the pre-26.05 defaults explicitly.
    withRuby = true;
    withPython3 = true;
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
