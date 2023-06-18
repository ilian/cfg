local Plugin = { 'neovim/nvim-lspconfig' }
local user = {}

Plugin.dependencies = {
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'williamboman/mason-lspconfig.nvim', lazy = true },
  {
    'williamboman/mason.nvim',
    cmd = { 'Mason', 'LspInstall', 'LspUnInstall' },
    config = function() user.setup_mason() end
  },
  -- Autoconfigure Neovim API, set up in lsp/lua_ls.lua
  {"folke/neodev.nvim"},
  -- LSP status UI
  {'j-hui/fidget.nvim', tag = 'legacy', opts = {} },
  -- TODO: Set up null-ls
}

Plugin.cmd = 'LspInfo'

Plugin.event = { 'BufReadPre', 'BufNewFile' }

function Plugin.init()
  local sign = function(opts)
    -- See :help sign_define()
    vim.fn.sign_define(opts.name, {
      texthl = opts.name,
      text = opts.text,
      numhl = ''
    })
  end

  sign({ name = 'DiagnosticSignError', text = '✘' })
  sign({ name = 'DiagnosticSignWarn', text = '▲' })
  sign({ name = 'DiagnosticSignHint', text = '⚑' })
  sign({ name = 'DiagnosticSignInfo', text = '»' })

  -- See :help vim.diagnostic.config()
  vim.diagnostic.config({
    virtual_text = false,
    severity_sort = true,
    float = {
      border = 'rounded',
      source = 'always',
    },
  })

  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
    vim.lsp.handlers.hover,
    { border = 'rounded' }
  )

  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    { border = 'rounded' }
  )
end

function Plugin.config()
  -- See :help lspconfig-global-defaults
  local lspconfig = require('lspconfig')
  local lsp_defaults = lspconfig.util.default_config

  lsp_defaults.capabilities = vim.tbl_deep_extend(
    'force',
    lsp_defaults.capabilities,
    require('cmp_nvim_lsp').default_capabilities()
  )

  local group = vim.api.nvim_create_augroup('lsp_cmds', { clear = true })

  vim.api.nvim_create_autocmd('LspAttach', {
    group = group,
    desc = 'LSP actions',
    callback = user.on_attach
  })

  -- See :help mason-lspconfig-dynamic-server-setup
  require('mason-lspconfig').setup_handlers({
    function(server)
      -- See :help lspconfig-setup
      lspconfig[server].setup({})
    end,
    ['tsserver'] = function()
      lspconfig.tsserver.setup({
        settings = {
          completions = {
            completeFunctionCalls = true
          }
        }
      })
    end,
    ['lua_ls'] = function()
      require('plugins.lsp.lua_ls')
    end
  })
end

function user.setup_mason()
  -- See :help mason-settings
  require('mason').setup({
    ui = { border = 'rounded' }
  })

  -- See :help mason-lspconfig-settings
  require('mason-lspconfig').setup({
    ensure_installed = {
      'eslint',
      'tsserver',
      'html',
      'cssls',
      'lua_ls',
      'terraformls',
      'jsonnet_ls',
      'bashls',
      'nil_ls',
      'rust_analyzer',
    }
  })
end

function user.on_attach()
  local bufmap = function(mode, lhs, rhs)
    local opts = { buffer = true }
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  -- You can search each function in the help page.
  -- For example :help vim.lsp.buf.hover()

  bufmap('n', '<leader>rn', vim.lsp.buf.rename)
  bufmap('n', '<leader>ca', vim.lsp.buf.code_action)

  bufmap('n', 'K', vim.lsp.buf.hover)
  bufmap('n', 'gd', vim.lsp.buf.definition)
  bufmap('n', 'gD', vim.lsp.buf.declaration)
  bufmap('n', 'gi', vim.lsp.buf.implementation)
  bufmap('n', 'go', vim.lsp.buf.type_definition)
  bufmap('n', 'gr', '<cmd>Telescope lsp_references<cr>')
  bufmap('n', 'gs', vim.lsp.buf.signature_help)
  bufmap({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>')
  bufmap('n', 'gl', vim.diagnostic.open_float)
  bufmap('n', '[d', vim.diagnostic.goto_prev)
  bufmap('n', ']d', vim.diagnostic.goto_next)
  bufmap('n', '<leader>s', '<cmd>Telescope lsp_document_symbols<cr>')
  bufmap('n', '<leader>S', '<cmd>Telescope lsp_workspace_symbols<cr>')
  bufmap('n', '<leader>d', '<cmd>Telescope diagnostics bufnr=0<cr>')
  -- Workspace diagnostics
  bufmap('n', '<leader>D', '<cmd>Telescope diagnostics<cr>')
end

return Plugin
