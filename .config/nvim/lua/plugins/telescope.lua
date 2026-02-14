
return {
  'nvim-telescope/telescope.nvim', version = '0.2.*',
  dependencies = {
    'nvim-lua/plenary.nvim', -- Required dependency
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }, -- Optional, for C-based fzf sorter
  },
  config = function()
    -- require("telescope").setup{ ... } -- Optional setup
  end,
  keys = {
    -- Keymaps also enable lazy loading on first use
    { '<leader>ff', function() require('telescope.builtin').find_files({ find_command = {'rg', '--files', '--hidden', '-g', '!.git'}}) end, desc = '[F]ind [F]iles' },
    { '<leader>fg', function() require('telescope.builtin').live_grep() end, desc = '[F]ind via [G]rep' },
    { '<leader>fb', function() require('telescope.builtin').buffers() end, desc = '[F]ind [B]uffers' },
    { '<leader>fh', function() require('telescope.builtin').help_tags() end, desc = '[F]ind [H]elp Tags' },
  },
}
