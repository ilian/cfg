-- Language-agnostic go to definition for projects without a language server.
-- Searches with ripgrep on demand instead of indexing the whole project.
return {
  'pechorin/any-jump.vim',
  cond = not vim.g.vscode,
  cmd = { 'AnyJump', 'AnyJumpVisual', 'AnyJumpArg', 'AnyJumpBack', 'AnyJumpLastResults' },
  init = function()
    -- <leader>ab and <leader>al would delay <leader>a
    vim.g.any_jump_disable_default_keybindings = 1
    -- Searches block the editor, so only look up references when pressing r
    vim.g.any_jump_references_enabled = 0
  end,
}
