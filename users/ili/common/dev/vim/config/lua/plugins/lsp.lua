if vim.g.vscode then
  local vscode = require("vscode")

  vim.keymap.set("n", "<leader>r", function()
    vscode.call("editor.action.rename")
  end)

  vim.keymap.set("n", "<leader>d", function()
    vscode.call("workbench.action.problems.focus")
  end)

  vim.keymap.set("n", "<leader>ca", function()
    vscode.call("editor.action.codeAction")
  end)

  return {}
end

-- TODO: Add LSP for non-VSCode context
return {}
