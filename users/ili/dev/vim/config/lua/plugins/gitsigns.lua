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
    }
  }
}
