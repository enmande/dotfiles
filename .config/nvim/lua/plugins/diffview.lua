require('diffview').setup({
  use_icons = false,
})

vim.keymap.set('n', '<leader>gd', function()
  local view = require('diffview.lib').get_current_view()
  if view then
    vim.cmd('DiffviewClose')
  else
    vim.cmd('DiffviewOpen')
  end
end, { desc = 'Toggle git diff view' })

vim.keymap.set('n', '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', { desc = 'File history (current file)' })
vim.keymap.set('v', '<leader>gh', '<cmd>DiffviewFileHistory<cr>', { desc = 'File history (selection)' })
