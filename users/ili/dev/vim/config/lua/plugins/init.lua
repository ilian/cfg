local Plugins = {
  {'tpope/vim-rhubarb'}, -- GitHub integration for fugitive
                         -- TODO: Add to git.lua?
  {'ruifm/gitlinker.nvim', opts = {}}, -- <leader>gy to copy link to Git web ui
  {'romainl/vim-cool'}, -- Disable search highlighting when done searching
  {"folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = {}},
  {'windwp/nvim-autopairs', event = "InsertEnter", opts = {} },
  {'airblade/vim-rooter'},
  {'wellle/targets.vim'},
  {'tpope/vim-repeat'},
  {'kyazdani42/nvim-web-devicons', lazy = true},
  -- Comment lines: selection (gc, gb), normal (gcc, gbc)
  {'numToStr/Comment.nvim', config = true, event = 'VeryLazy'},

  -- Themes
  {'rebelot/kanagawa.nvim'},
  {'folke/tokyonight.nvim'},
}

return Plugins
