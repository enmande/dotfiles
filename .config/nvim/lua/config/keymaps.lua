-- Help for word under cursor
vim.keymap.set('n', '<leader>h', ':help <C-r><C-w><CR>', { desc = 'Help for word under cursor' })

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
