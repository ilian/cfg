if vim.g.vscode then
  local vscode = require("vscode")
  vim.keymap.set("n", "<leader>f", function() vscode.action("workbench.action.quickOpen") end)
  vim.keymap.set("n", "<leader>/", function() vscode.action("workbench.action.findInFiles") end)
  return {}
end

return {
  'nvim-telescope/telescope.nvim',

  branch = '0.1.x',

  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },

  cmd = { 'Telescope' },

  init = function()
    -- See :help telescope.builtin
    vim.keymap.set('n', '<leader>?', '<cmd>Telescope oldfiles<cr>')
    vim.keymap.set('n', '<leader>bl', '<cmd>Telescope buffers<cr>')
    vim.keymap.set('n', '<leader>f', '<cmd>Telescope find_files<cr>')
    vim.keymap.set('n', '<leader>/', '<cmd>Telescope live_grep<cr>')
  end,

  config = function()
    require('telescope').load_extension('fzf')
  end
}
