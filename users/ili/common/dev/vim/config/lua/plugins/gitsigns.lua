if vim.g.vscode then
  -- Built-in
  return {}
end

return {
  'lewis6991/gitsigns.nvim',

  name = 'gitsigns',

  event = { 'BufReadPre', 'BufNewFile' },

  -- See :help gitsigns-usage
  opts = {
    signs = {
      add = { text = '▎' },
      change = { text = '▎' },
      delete = { text = '➤' },
      topdelete = { text = '➤' },
      changedelete = { text = '▎' },
    },
  },

  config = function(_, opts)
    require('gitsigns').setup(opts)

    local branch_base
    local current_base = 'HEAD'

    vim.defer_fn(function()
      for _, ref in ipairs({ 'main', 'master' }) do
        vim.fn.system({ 'git', 'rev-parse', '--verify', '--quiet', ref })
        if vim.v.shell_error == 0 then
          branch_base = ref
          break
        end
      end
      if branch_base then
        require('gitsigns').change_base(branch_base, true)
        current_base = branch_base
      end
    end, 300)

    vim.keymap.set('n', '<leader>gt', function()
      if not branch_base then
        vim.notify('gitsigns: no main/master branch detected', vim.log.levels.WARN)
        return
      end
      current_base = current_base == branch_base and 'HEAD' or branch_base
      require('gitsigns').change_base(current_base, true)
      vim.notify('gitsigns base: ' .. current_base)
    end, { desc = 'Toggle gitsigns base (branch/HEAD)' })
  end,
}
