require('config.options')
require('config.keymaps')
require('config.statusline')

if not vim.g.vscode then
  require('config.lsp')
  require('config.lazy')
end
