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

          map('gd', vim.lsp.buf.definition, 'Go to definition')
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
