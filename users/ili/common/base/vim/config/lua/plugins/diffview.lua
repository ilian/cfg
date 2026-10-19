if vim.g.vscode then
  -- Built-in
  return {}
end

return {
  'sindrets/diffview.nvim',

  name = 'diffview',

  dependencies = {
    { 'nvim-lua/plenary.nvim' },
  },

  cmd = {
    'DiffviewOpen',
    'DiffviewClose',
    'DiffviewFileHistory',
    'DiffviewToggleFiles',
    'DiffviewFocusFiles',
  },

  init = function()
    -- See :help diffview
    vim.keymap.set('n', '<leader>gd', '<cmd>DiffviewOpen<cr>', { desc = 'Diffview: open diff' })
    vim.keymap.set('n', '<leader>gq', '<cmd>DiffviewClose<cr>', { desc = 'Diffview: close' })
    vim.keymap.set('n', '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', { desc = 'Diffview: file history' })
    vim.keymap.set('n', '<leader>gH', '<cmd>DiffviewFileHistory<cr>', { desc = 'Diffview: repo history' })
  end,

  opts = {},
}
