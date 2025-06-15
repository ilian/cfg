-- if vim.g.vscode then
--
--    return {}
--end

return {
	"kelly-lin/ranger.nvim",

	config = function()
		-- Replacing netrw does not seem to work yet
		require("ranger-nvim").setup({ replace_netrw = true })
		vim.api.nvim_set_keymap("n", "<leader>t", "", {
			noremap = true,
			callback = function()
				require("ranger-nvim").open(true)
			end,
		})
	end,
}
