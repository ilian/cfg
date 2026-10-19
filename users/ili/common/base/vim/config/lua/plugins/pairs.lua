if vim.g.vscode then
  -- Built-in
  return {}
end

return {
  { 'echasnovski/mini.pairs', enabled = false },
  { 'windwp/nvim-autopairs',  event = "InsertEnter", opts = {} },
}
