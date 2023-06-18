-- Space as leader key
vim.g.mapleader = ' '

-- Switch to alternate file with double leader
vim.keymap.set('n', '<leader><leader>', '<c-^>')

-- Shortcuts
vim.keymap.set('n', '<leader>a', ':keepjumps normal! ggVG<cr>')

-- Use different mappings to yank to vim and OS clipboard
vim.keymap.set({'n', 'x'}, '<leader>y', '"+y')
vim.keymap.set('n', '<leader>Y', '"+Y')
vim.keymap.set({'n', 'x'}, 'cv', '"+p')

-- Replace highlight with contents of default register without modifying it
vim.keymap.set('x', '<leader>p', '"_dP')

-- Do not modify default register when deleting single character
vim.keymap.set({'n', 'x'}, 'x', '"_x')

-- Pipe selection to specified command and replace contents with output
vim.keymap.set('x', '|', ':!')

-- Keep cursor at the same position when joining lines
vim.keymap.set('n', 'J', 'mzJ`z')

-- Center cursor when searching
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Center cursoe when scrolling
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- Commands
vim.keymap.set('n', '<leader>w', '<cmd>write<cr>')
vim.keymap.set('n', '<leader>bq', '<cmd>bdelete<cr>')

