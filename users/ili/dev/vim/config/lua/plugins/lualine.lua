return {
  'nvim-lualine/lualine.nvim',

  name = 'lualine',

  event = 'VeryLazy',

  -- See :help lualine.txt
  opts = {
    options = {
      theme = 'auto',
      icons_enabled = true,
      component_separators = '|',
      section_separators = '',
      disabled_filetypes = {
        statusline = { 'NvimTree' }
      }
    },
  },
  init = function()
    vim.opt.showmode = false
  end
}
