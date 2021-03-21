{ pkgs, ... }:

let
  luaDir = ./config;
in {
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      #sonokai
      vim-gruvbox8

      vim-polyglot          # Language pack collection
      nvim-lspconfig
      completion-nvim
      nvim-treesitter

      ranger-vim            # File manager integration
      bclose-vim            # ranger-vim dependency

      vim-cool              # No highlighting after move
      vim-rooter            # cd to project root, works well with fzf
      fzf-vim
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
      rnix-lsp
      clang-tools # clangd
      nodePackages.vscode-html-languageserver-bin
      nodePackages.vscode-css-languageserver-bin
      nodePackages.vscode-json-languageserver
      nodePackages.svelte-language-server
      nodePackages.typescript
      nodePackages.typescript-language-server
    ];
    extraConfig = ''
      if filereadable($HOME . "/.vimrc")
        source ~/.vimrc
      endif

      let mapleader = " "
      nnoremap ; :

      set nowrap
      set cursorline             " Highlight current line
      set clipboard+=unnamedplus " Sync clipboard with OS
      set mouse=a                " Enable mouse support
      set smartcase
      set ignorecase
      set expandtab              " Insert spaces instead of TAB
      set tabstop=2              " Expand TAB to 2 spaces
      set shiftwidth=2
      set softtabstop=2
      set scrolloff=2            " View context lines above/below cursor
      set nojoinspaces           " Do not add extra spaces after joining sentences
      set splitright             " Create vsplits on the right
      set splitbelow             " Create split on the bottom

      " Keep undo history after quit
      if !isdirectory($HOME."/.vim")
        call mkdir($HOME."/.vim", "", 0755)
      endif
      if !isdirectory($HOME."/.vim/undo-dir")
        call mkdir($HOME."/.vim/undo-dir", "", 0700)
      endif
      set undodir=~/.vim/undo-dir
      set undofile

      " Load lua config
      set runtimepath^=${luaDir}
      :luafile ${luaDir}/init.lua

      if has('termguicolors')
        set termguicolors
      endif

      set background=dark
      colorscheme gruvbox8

      nnoremap <silent> <C-p> :FZF<cr>
      nnoremap <leader>; :Buffers<cr>

      " Temporarily disable until the following issue is fixed:
      " https://github.com/ntpeters/vim-better-whitespace/issues/125
      let g:better_whitespace_enabled=0
      let g:strip_whitespace_on_save=1
    '';

  };

  home.sessionVariables.EDITOR = "vim";
}
