return {
  'kyazdani42/nvim-tree.lua',

  name = 'nvim-tree',

  cmd = { 'NvimTreeToggle' },

  -- See :help nvim-tree-setup
  opts = {
    hijack_cursor = false,
    on_attach = function(bufnr)
      local bufmap = function(lhs, rhs, desc)
        vim.keymap.set('n', lhs, rhs, { buffer = bufnr, desc = desc })
      end

      -- :help nvim-tree.api
      local api = require('nvim-tree.api')

      bufmap('L', api.node.open.edit, 'Expand folder or go to file')
      bufmap('H', api.node.navigate.parent_close, 'Close parent folder')
      bufmap('gh', api.tree.toggle_hidden_filter, 'Toggle hidden files')
    end
  },

  init = function()
    vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<cr>')
  end
}
