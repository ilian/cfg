return {
  'ntpeters/vim-better-whitespace',

  init = function()
    vim.g.better_whitespace_enabled = 1
    vim.g.strip_whitespace_on_save = 1
    vim.g.strip_whitespace_confirm = 1
    vim.g.better_whitespace_operator = '_s'
    vim.g.better_whitespace_filetypes_blacklist = {
      'diff',
      'unite',
      'qf',
      'help',
      'toggleterm',
    }
  end
}
