require('yazi').setup({
  open_for_directories = true,
  keymaps = {
    show_help = '<f1>',
  },
})

vim.keymap.set({ 'n', 'v' }, '<leader>e', '<cmd>Yazi<cr>', { desc = 'Open yazi at the current file' })
vim.keymap.set('n', '<leader>yi', '<cmd>Yazi cwd<cr>', { desc = "Open the file manager in nvim's working directory" })
vim.keymap.set('n', '<leader>yo', '<cmd>Yazi toggle<cr>', { desc = 'Resume the last yazi session' })
