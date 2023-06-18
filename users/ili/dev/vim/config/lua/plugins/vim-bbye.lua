return {
  'moll/vim-bbye',

  cmd = 'Bdelete',

  init = function()
    vim.keymap.set('n', '<leader>bc', '<cmd>Bdelete<CR>')
  end
}
