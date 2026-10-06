-- Help for word under cursor
vim.keymap.set('n', '<leader>h', ':help <C-r><C-w><CR>', { desc = 'Help for word under cursor' })
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = "Show line diagnostics" })


-- Quickfix toggle
vim.keymap.set('n', '<leader>q', function()
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      vim.cmd.cclose()
      return
    end
  end
  vim.cmd.copen()
end, { desc = 'Toggle quickfix' })

-- Command: show all matches
vim.keymap.set('c', '<C-Space>', '<C-d>', { desc = 'Show all matches' })

-- Terminal
vim.keymap.set('t', '<C-w><C-w>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('t', '<C-w>', '<C-\\><C-n><C-w>', { desc = 'Window navigation from terminal' })

vim.api.nvim_create_augroup('TerminalComfort', { clear = true })
vim.api.nvim_create_autocmd('TermOpen', {
  group = 'TerminalComfort',
  callback = function()
    vim.keymap.set('n', 'i', 'a', { buffer = true })
  end,
})

-- Folds
local fold_keys = {
  { '<leader>oo', 'za', 'editor.toggleFold',            'Toggle fold' },
  { '<leader>oO', 'zA', 'editor.toggleFoldRecursively', 'Toggle fold recursively' },
  { '<leader>oc', 'zM', 'editor.foldAll',               'Close all folds' },
  { '<leader>oe', 'zR', 'editor.unfoldAll',             'Open all folds' },
  { '<leader>oj', 'zj', 'editor.gotoNextFold',          'Next fold' },
  { '<leader>ok', 'zk', 'editor.gotoPreviousFold',      'Previous fold' },
}
for _, k in ipairs(fold_keys) do
  local lhs, vim_keys, vscode_cmd, desc = unpack(k)
  local rhs = vim.g.vscode and function() require('vscode').action(vscode_cmd) end or vim_keys
  vim.keymap.set('n', lhs, rhs, { desc = desc })
end

if vim.g.vscode then
  vim.keymap.set('n', 'gd', function() require('vscode').action('editor.action.revealDefinition') end)
  vim.keymap.set('n', 'gr', function() require('vscode').action('editor.action.goToReferences') end)
end
