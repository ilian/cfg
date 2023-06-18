return {
  'tpope/vim-fugitive',

  init = function()
    vim.keymap.set('n', '<leader>gs', '<cmd>Git<CR>')
  end
}
