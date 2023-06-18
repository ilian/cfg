return {
  'lukas-reineke/indent-blankline.nvim',

  name = 'indent_blankline',

  event = { 'BufReadPost', 'BufNewFile' },

  -- See :help indent-blankline-setup
  opts = {
    char = '▏',
    show_trailing_blankline_indent = false,
    show_first_indent_level = false,
    use_treesitter = true,
    show_current_context = false
  }
}
