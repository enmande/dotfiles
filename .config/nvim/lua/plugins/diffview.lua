return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory', 'DiffviewClose' },
  keys = {
    {
      '<leader>gd',
      function()
        local view = require('diffview.lib').get_current_view()
        if view then
          vim.cmd('DiffviewClose')
        else
          vim.cmd('DiffviewOpen')
        end
      end,
      desc = 'Toggle git diff view',
    },
    { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'File history (current file)' },
    { '<leader>gh', mode = 'v', '<cmd>DiffviewFileHistory<cr>', desc = 'File history (selection)' },
  },
}
