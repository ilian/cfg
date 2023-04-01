{ pkgs, ... }:

let
  luaDir = ./config;
in {
  programs.neovim = {
    enable = true;
    package = pkgs.unstable.neovim-unwrapped;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      #sonokai
      vim-gruvbox8
      tokyonight-nvim
      kanagawa-nvim

      #vim-polyglot          # Language pack collection
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      luasnip
      nvim-treesitter.withAllGrammars

      ranger-vim            # File manager
      fzf-vim
      vim-cool              # No highlighting after move
      vim-rooter            # cd to project root, works well with fzf
      indent-blankline-nvim # Add indentation guides to all lines
      pear-tree             # Auto-pair parentheses, quotes, HTML tags, ...
      vim-better-whitespace # Highlight and delete whitespace
      editorconfig-vim
      vim-signify           # Show modified lines (vcs)
      vim-fugitive          # Git
      vim-rhubarb           # GitHub integration for fugitive
      gitlinker-nvim        # <leader>gy to copy permalink to Git frontend
      plenary-nvim          # Dependency of gitlinker
      vim-startuptime       # :StartupTime
      vim-table-mode        # <leader>tm switches to table mode
    ];
    extraPackages = with pkgs; [
      # C code navigation
      cscope
      ctags

      # C/C++ code index generation for clangd
      bear

      # LSP servers
      rust-analyzer
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

      if has('termguicolors')
        set termguicolors
      endif

      set background=dark
      colorscheme kanagawa

      set nu                     " Show line numbers
      set relativenumber
      set nowrap
      set cursorline             " Highlight current line
      set mouse=a                " Enable mouse support
      set ignorecase
      set smartcase              " Case-sensitive search iff pattern has uppercase char
      set expandtab              " Insert spaces instead of TAB
      set tabstop=2              " Expand TAB to 2 spaces
      set shiftwidth=2
      set softtabstop=2
      set scrolloff=2            " View context lines above/below cursor
      set nojoinspaces           " Do not add extra spaces after joining sentences
      set splitright             " Create vsplits on the right
      set splitbelow             " Create split on the bottom
      set colorcolumn=80         " Show line at 80 chars

      let mapleader = " "
      nnoremap ; :
      " Use different mappings to yank to vim and OS clipboard
      nnoremap <leader>y "+y
      vnoremap <leader>y "+y
      nnoremap <leader>Y "+Y
      " Search globally
      nnoremap <leader>/ :Rg<cr>
      " Toggle buffer by pressing <leader> twice
      nnoremap <leader><leader> <c-^>
      nnoremap <leader>gs :Git<cr>
      " Pick a file to edit using Ranger
      nnoremap <leader>f :RangerEdit<cr>
      " Open file picker
      nnoremap <silent> <C-p> :Files<cr>
      " Allow <C-p> while picking files in Ranger
      tmap <silent> <C-p> <C-\><C-n>:Files<cr>
      nnoremap <leader>; :Buffers<cr>

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

      let g:strip_whitespace_on_save=1
      let g:pear_tree_repeatable_expand=0 " Do not remove closing pair on return
    '';

  };
}
