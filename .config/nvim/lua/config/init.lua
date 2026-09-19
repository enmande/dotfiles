vim.g.loaded_netrwPlugin = 1  -- yazi handles directories; must be set before plugins load

vim.pack.add({ "https://github.com/nvim-lua/plenary.nvim" })
vim.pack.add({ "https://github.com/morhetz/gruvbox" })
vim.pack.add({ "https://github.com/nvim-telescope/telescope.nvim" })
vim.pack.add({ "https://github.com/mikavilpas/yazi.nvim" })

require('config.options')
require('config.keymaps')
require('config.statusline')

if not vim.g.vscode then
  require('config.lsp')
  require('plugins.gruvbox')
  require('plugins.telescope')
  require('plugins.yazi')
end
