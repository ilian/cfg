-- Autoconfigure Neovim runtime and plugin dirs
-- Neodev needs to be set up before lua_ls
require('neodev').setup()
local lspconfig = require('lspconfig')

lspconfig.lua_ls.setup({
  settings = {
    Lua = {
      workspace = {
        checkThirdParty = false
      },
      telemetry = {
        enable = false
      },
    }
  }
})

