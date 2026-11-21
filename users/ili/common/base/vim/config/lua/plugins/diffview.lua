if vim.g.vscode then
  -- Built-in
  return {}
end

return {
  'sindrets/diffview.nvim',

  name = 'diffview',

  dependencies = {
    { 'nvim-lua/plenary.nvim' },
  },

  cmd = {
    'DiffviewOpen',
    'DiffviewClose',
    'DiffviewFileHistory',
    'DiffviewToggleFiles',
    'DiffviewFocusFiles',
  },

  init = function()
    local function git(dir, args)
      local res = vim.system(vim.list_extend({ 'git', '-C', dir }, args), { text = true }):wait()
      if res.code == 0 then
        return vim.trim(res.stdout)
      end
    end

    -- Returns the repository and base branch of the current buffer, falling
    -- back to cwd like diffview does. Full ref names avoid matching tags.
    local function review_context()
      local dir = vim.fn.getcwd()
      if vim.bo.buftype == '' and vim.api.nvim_buf_get_name(0) ~= '' then
        dir = vim.fn.expand('%:p:h')
      end
      local root = git(dir, { 'rev-parse', '--show-toplevel' })
      if not root then
        vim.notify('diffview: not in a git repository', vim.log.levels.WARN)
        return
      end
      local base = git(root, { 'symbolic-ref', '--quiet', 'refs/remotes/origin/HEAD' })
      if not base then
        for _, ref in ipairs({
          'refs/remotes/origin/main', 'refs/remotes/origin/master', 'refs/heads/main', 'refs/heads/master',
        }) do
          if git(root, { 'rev-parse', '--verify', '--quiet', ref }) then
            base = ref
            break
          end
        end
      end
      if not base then
        vim.notify('diffview: no base branch detected', vim.log.levels.WARN)
        return
      end
      return root, base
    end

    -- The Lua API takes an argument list, so refs and paths are not re-parsed
    -- by diffview's command-line scanner.
    -- --imply-local makes the HEAD side of the range use the working tree
    -- files, so LSP (go to definition, references, ...) works while reviewing.
    vim.keymap.set('n', '<leader>gb', function()
      local root, base = review_context()
      if root then
        require('diffview').open({ '-C' .. root, base .. '...HEAD', '--imply-local' })
      end
    end, { desc = 'Diffview: review branch against base' })

    -- Commit buffers come from git and have no LSP; use gf to jump to the
    -- working tree file.
    vim.keymap.set('n', '<leader>gc', function()
      local root, base = review_context()
      if root then
        require('diffview').file_history(nil, { '-C' .. root, '--range=' .. base .. '..HEAD' })
      end
    end, { desc = 'Diffview: review branch commits' })

    -- See :help diffview
    vim.keymap.set('n', '<leader>gd', '<cmd>DiffviewOpen<cr>', { desc = 'Diffview: open diff' })
    vim.keymap.set('n', '<leader>gq', '<cmd>DiffviewClose<cr>', { desc = 'Diffview: close' })
    vim.keymap.set('n', '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', { desc = 'Diffview: file history' })
    vim.keymap.set('n', '<leader>gH', '<cmd>DiffviewFileHistory<cr>', { desc = 'Diffview: repo history' })
  end,

  opts = {},
}
