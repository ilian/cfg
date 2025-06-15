if vim.g.vscode then
  -- Built-in
  return {}
end

return {
  'lukas-reineke/indent-blankline.nvim',

  name = 'indent_blankline',

  main = "ibl",

  event = { 'BufReadPost', 'BufNewFile' },

  -- See :help indent-blankline-setup
  opts = {
    indent = { char = '▏'},
  }
}
