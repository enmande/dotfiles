if vim.fn.executable('rg') == 0 then
  vim.notify(
    "telescope: 'rg' (ripgrep) not found on PATH - find_files/live_grep will silently return no results. Install with `brew install ripgrep`.",
    vim.log.levels.WARN,
    { title = 'telescope.nvim' }
  )
end

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', function()
  builtin.find_files({ find_command = { 'rg', '--files', '--hidden', '-g', '!.git' } })
end, { desc = '[F]ind [F]iles' })

vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = '[F]ind via [G]rep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = '[F]ind [B]uffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '[F]ind [H]elp Tags' })
