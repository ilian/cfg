-- Provides :StripWhitespace, :StripWhitespaceOnChangedLines
return {
	"ntpeters/vim-better-whitespace",

	init = function()
		vim.g.better_whitespace_enabled = 0
		if vim.g.vscode then
			-- Built-in
			vim.g.strip_whitespace_on_save = 0
			vim.g.strip_whitespace_confirm = 0
		else
			vim.g.strip_whitespace_on_save = 1
			vim.g.strip_whitespace_confirm = 1
		end
		vim.g.better_whitespace_operator = "<leader>s"
		vim.g.better_whitespace_filetypes_blacklist = {
			"diff",
			"unite",
			"qf",
			"help",
			"toggleterm",
		}
	end,
}
