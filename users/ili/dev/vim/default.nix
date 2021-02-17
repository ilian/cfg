{ pkgs, ... }:

let
  luaDir = ./config;
in {
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      #sonokai
      vim-gruvbox8

      nvim-lspconfig
      completion-nvim
      nvim-treesitter

      ranger-vim            # File manager integration
      bclose-vim            # ranger-vim dependency

      vim-cool              # No highlighting after move
      vim-rooter            # cd to project root, works well with fzf
      fzf-vim
      vim-nix               # Nix language support
      pear-tree
      vim-better-whitespace # Highlight and delete whitespace
      editorconfig-vim
      vim-signify           # Show modified lines (vcs)
      vim-fugitive          # Git
      vim-startuptime       # :StartupTime
    ];
    extraPackages = with pkgs; [
      # Treesitter dependencies
      stdenv.cc.cc

      # C code navigation
      cscope
      ctags

      # C/C++ code index generation for clangd
      bear

      # LSP servers
      # C++
      clang-tools # clangd

      # Web
      nodePackages.vscode-html-languageserver-bin
      nodePackages.vscode-css-languageserver-bin
      nodePackages.svelte-language-server

      nodePackages.vscode-json-languageserver
    ];
    extraConfig = ''
      if filereadable($HOME . "/.vimrc")
        source ~/.vimrc
      endif

      let mapleader = " "

      set cursorline             " Highlight current line
      set clipboard+=unnamedplus " Sync clipboard with OS
      set mouse=a                " Enable mouse support
      set smartcase
      set ignorecase

      autocmd BufNewFile,BufRead *.svelte set filetype=svelte
      set runtimepath^=${luaDir}
      :luafile ${luaDir}/init.lua

      if has('termguicolors')
        set termguicolors
      endif

      set background=dark
      colorscheme gruvbox8

      nnoremap <silent> <C-p> :FZF<cr>

      let g:better_whitespace_enabled=1
      let g:strip_whitespace_on_save=1
    '';

  };

  home.sessionVariables.EDITOR = "vim";
}
