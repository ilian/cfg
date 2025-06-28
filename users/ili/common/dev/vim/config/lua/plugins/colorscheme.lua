if vim.g.vscode then
  -- Handled by a vscode extension
  return {}
end

return {
  "rebelot/kanagawa.nvim",
  priority = 1000,
  config = function ()
    vim.cmd("colorscheme kanagawa")
  end
}
