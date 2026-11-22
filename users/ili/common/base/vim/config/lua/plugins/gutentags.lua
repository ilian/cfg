-- Language-agnostic go to definition for projects without a language server
return {
  'ludovicchabant/vim-gutentags',
  cond = not vim.g.vscode,
  init = function()
    -- Keep tags files out of project directories
    vim.g.gutentags_cache_dir = vim.fn.stdpath('cache') .. '/tags'
    -- Respect .gitignore to skip node_modules, vendor, build output, ...
    vim.g.gutentags_file_list_command = 'rg --files'

    -- The Ruby ftplugin resets 'tags' when :edit re-triggers FileType, while
    -- gutentags only adds its tags file on the first load of a buffer.
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'ruby',
      callback = function()
        local file = (vim.b.gutentags_files or {}).ctags
        if file and not vim.tbl_contains(vim.split(vim.fn.eval('&tags'), ','), file) then
          vim.cmd('setlocal tags^=' .. vim.fn.fnameescape(file))
        end
      end,
    })
  end,
}
