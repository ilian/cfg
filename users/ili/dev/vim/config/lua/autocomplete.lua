local lspconf = require('lspconfig')

local on_attach = function(_, bufnr)
  require('completion').on_attach() -- Use nvim-lua/completion-nvim
  local opts = { noremap=true, silent=true }
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gla', '<cmd>lua vim.lsp.buf.code_action()                               <CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'glD', '<cmd>lua vim.lsp.buf.declaration()                               <CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gld', '<cmd>lua vim.lsp.buf.definition()                                <CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K',   '<cmd>lua vim.lsp.buf.hover()                                     <CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gli', '<cmd>lua vim.lsp.buf.implementation()                            <CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gls', '<cmd>lua vim.lsp.buf.signature_help()                            <CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'glt', '<cmd>lua vim.lsp.buf.type_definition()                           <CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'glr', '<cmd>lua vim.lsp.buf.rename()                                    <CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'glR', '<cmd>lua vim.lsp.buf.references()                                <CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gl?', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()              <CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'glw', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'glq', '<cmd>lua vim.lsp.diagnostic.set_loclist()                        <CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '[e',  '<cmd>lua vim.lsp.diagnostic.goto_prev()                          <CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ']e',  '<cmd>lua vim.lsp.diagnostic.goto_next()                          <CR>', opts)
end

local servers = {
  clangd = {},
  jsonls = {},
  cssls = {},
  html = {},
  svelte = {},
  elixirls = {
    cmd = {"elixir-ls"}
  },
}
for server, options in pairs(servers) do
  options.on_attach = on_attach
  lspconf[server].setup(options)
end

vim.api.nvim_command([[command! Format execute 'lua vim.lsp.buf.formatting()']])

-- vim.g.completion_enable_snippet = 'UltiSnips'
vim.g.completion_confirm_key = '<C-y>'
vim.g.completion_matching_strategy_list = {'exact', 'substring', 'fuzzy'}
vim.g.completion_matching_smart_case = 1
vim.g.completion_trigger_on_delete = 1
vim.o.completeopt = 'menuone,noinsert,noselect'
vim.o.shortmess = vim.o.shortmess .. 'c'
vim.wo.signcolumn = 'yes'

-- Use <Tab> and <S-Tab> to navigate through popup menu
vim.api.nvim_set_keymap('i', '<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', {expr = true})
vim.api.nvim_set_keymap('i', '<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<Tab>"', {expr = true})
