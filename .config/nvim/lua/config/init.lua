require('config.options')
require('config.keymaps')

if not vim.g.vscode then
  require('config.lsp')
  require('config.lazy')
end
