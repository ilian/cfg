if vim.g.vscode then
  local vscode = require("vscode")

  vim.keymap.set("n", "<leader>r", function()
    vscode.call("editor.action.rename")
  end)

  vim.keymap.set("n", "<leader>d", function()
    vscode.call("workbench.action.problems.focus")
  end)

  vim.keymap.set("n", "<leader>ca", function()
    vscode.call("editor.action.codeAction")
  end)

  return {}
end

-- Neovim points 'tagfunc' at the language server when one attaches and falls
-- back to ctags when it has no result, so this works with and without LSP.
-- g<C-]> jumps directly on a single match and lists candidates otherwise.
-- Without either, e.g. outside a project, use the builtin local declaration.
vim.keymap.set('n', 'gd', function()
  if vim.bo.tagfunc == '' and #vim.fn.tagfiles() == 0 then return 'gd' end
  return 'g<C-]>'
end, { expr = true, desc = 'Go to definition' })

return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      for _, server in ipairs({ 'pyright', 'gopls', 'elixirls', 'ruby_lsp' }) do
        vim.lsp.enable(server)
      end

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local function map(lhs, rhs, desc)
            vim.keymap.set('n', lhs, rhs, { buffer = args.buf, desc = desc })
          end

          map('gD', vim.lsp.buf.declaration, 'Go to declaration')
          map('gr', vim.lsp.buf.references, 'References')
          map('gi', vim.lsp.buf.implementation, 'Go to implementation')
          map('gy', vim.lsp.buf.type_definition, 'Type definition')
          map('K', vim.lsp.buf.hover, 'Hover')
          map('<leader>r', vim.lsp.buf.rename, 'Rename')
          map('<leader>ca', vim.lsp.buf.code_action, 'Code action')
          map('<leader>d', function()
            for _, win in ipairs(vim.fn.getwininfo()) do
              if win.loclist == 1 then vim.cmd('lclose') return end
            end
            vim.diagnostic.setloclist()
          end, 'Toggle diagnostics list')
          map('[d', function() vim.diagnostic.jump({ count = -1, on_jump = vim.diagnostic.open_float }) end, 'Prev diagnostic')
          map(']d', function() vim.diagnostic.jump({ count = 1, on_jump = vim.diagnostic.open_float }) end, 'Next diagnostic')
        end,
      })
    end,
  },
}
