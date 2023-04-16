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
      fidget-nvim            # Show LSP status
      nvim-treesitter.withAllGrammars
      nvim-treesitter-context

      # Telescope with dependencies
      telescope-nvim
      plenary-nvim

      ranger-vim            # File manager
      vim-cool              # No highlighting after move
      vim-rooter            # cd to project root, works well with telescope
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
      #vim-table-mode        # <leader>tm switches to table mode (TODO: remove built-in key bindings, slows down <leader>t)
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
      set updatetime=100         " Time to react to changes (used by vim-signify, swap)
      set shortmess+=I           " Hide intro message


      let mapleader = " "

      " Telescope pickers
      nnoremap <leader>f :Telescope find_files<cr>
      nnoremap <leader>b :Telescope buffers<cr>
      nnoremap <leader>b :Telescope buffers<cr>
      nnoremap <leader>/ :Telescope live_grep<cr>
      " Find files tracked by Git and allow while picking files in Ranger
      nnoremap <C-p> :Telescope git_files<cr>
      tmap <silent> <C-p> <C-\><C-n>:Telescope git_files<cr>

      " Use different mappings to yank to vim and OS clipboard
      nnoremap <leader>y "+y
      vnoremap <leader>y "+y
      nnoremap <leader>Y "+Y

      " Replace highlight with contents of x register without modifying the register
      xnoremap <leader>p "_dP

      " Toggle buffer by pressing <leader> twice
      nnoremap <leader><leader> <c-^>

      " Git status
      nnoremap <leader>gs :Git<cr>

      " Pick a file to edit using Ranger
      nnoremap <leader>t :RangerEdit<cr>

      " Use | to pipe selection in visual mode or select mode to external command
      xnoremap \| :!

      " Keep cursor at the same position while joining lines
      nnoremap J mzJ`z

      " Keep cursor centered when searching
      nnoremap n nzzzv
      nnoremap N Nzzzv

      " Keep cursor centered when scrolling up/down half a screen
      nnoremap <C-d> <C-d>zz
      nnoremap <C-u> <C-u>zz


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

      let g:better_whitespace_enabled=0    " Marks parts of Ranger in Red otherwise...
      let g:better_whitespace_operator=""  " Don't configure any mappings since they conflict with LSP keybindings
      let g:strip_whitespace_on_save=1
      let g:pear_tree_repeatable_expand=0  " Do not remove closing pair on return
      let g:pear_tree_ft_disabled = ['TelescopePrompt'] " Allow <CR> to work in telescope
    '';

  };
}
