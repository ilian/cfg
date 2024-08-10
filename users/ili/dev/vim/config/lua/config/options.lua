vim.o.termguicolors = true
-- Show line numbers
vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false
-- Use same indentation for wrapped text (if enabled)
vim.o.breakindent = true
-- Highlight current line
vim.o.cursorline = true
vim.o.mouse = 'a'
vim.o.ignorecase = true
-- Case-insensitive search unless pattern has uppercase char, or \C
vim.o.smartcase = true
-- Expand TAB to 2 spaces
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
-- View context lines above/below cursor
vim.o.scrolloff = 2
-- Do not add extra spaces after joining sentences
vim.o.joinspaces = false
-- Create vsplits on the right
vim.o.splitright = true
-- Create split on the bottom
vim.o.splitbelow = true
-- Show line at 80 chars
vim.o.colorcolumn = "80"
-- Always show sign column to avoid layout shift when at least 1 sign exists
vim.o.signcolumn = 'yes'
vim.o.updatetime = 100

-- Keep undo history after quit (~/.local/state/nvim/undo/)
vim.o.undofile = true

-- Editor options are synced from vscode to neovim
-- Let's set the same options in vscode
if vim.g.vscode then
  vscode = require('vscode')
  vscode.update_config("editor.tabSize", 2, "global")
  vscode.update_config("editor.insertSpaces", true, "global")
  vscode.update_config("editor.lineNumbers", "relative", "global")
end