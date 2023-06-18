return {
  "kelly-lin/ranger.nvim",

  config = function()
    -- Replacing netrw does not seem to work yet
    require("ranger-nvim").setup({ replace_netrw = false })
    vim.api.nvim_set_keymap("n", "<leader>ef", "", {
      noremap = true,
      callback = function()
        require("ranger-nvim").open(true)
      end,
    })
  end,
}
