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

      vim-polyglot          # Language pack collection
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      luasnip
      #nvim-treesitter

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
      vim-startuptime       # :StartupTime
      emmet-vim             # Generate HTML from abbreviations
    ];
    extraPackages = with pkgs; [
      # Treesitter dependencies
      # gcc

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
      set colorcolumn=80         " Show line at 80 chars

      let mapleader = " "
      nnoremap ; :
      " Toggle buffer with <leader> <leader>
      nnoremap <leader><leader> <c-^>
      nnoremap <leader>f :RangerEdit<cr>
      nnoremap <silent> <C-p> :Files<cr>
      " Allow <C-p> in ranger
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


      " lua <<EOF
      " require'nvim-treesitter.configs'.setup {
      "   ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
      "   ignore_install = {}, -- List of parsers to ignore installing
      "   highlight = {
      "     enable = true,              -- false will disable the whole extension
      "     disable = {},  -- list of language that will be disabled
      "   },
      " }
      " EOF

      if has('termguicolors')
        set termguicolors
      endif

      set background=dark
      colorscheme gruvbox8

      " Temporarily disable until the following issue is fixed:
      " https://github.com/ntpeters/vim-better-whitespace/issues/125
      let g:better_whitespace_enabled=0
      let g:strip_whitespace_on_save=1
      let g:user_emmet_leader_key=','     " Use ,, to expand emmet abbreviation
      let g:pear_tree_repeatable_expand=0 " Do not remove closing pair on return

      " Rust
      let g:rustfmt_autosave = 1
      let g:rustfmt_emit_files = 1
      let g:rustfmt_fail_silently = 0
    '';

  };

  home.sessionVariables.EDITOR = "vim";
}
