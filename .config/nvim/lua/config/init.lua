vim.g.loaded_netrwPlugin = 1  -- yazi handles directories; must be set before plugins load

-- Pinned to commits at least 14 days old. To upgrade, change `version` here.
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name == 'nvim-treesitter' and ev.data.kind == 'update' then
      if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
      vim.cmd('TSUpdate')
    end
  end,
})

vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim",              version = "74b06c6c75e4eeb3108ec01852001636d85a932b" },
  { src = "https://github.com/morhetz/gruvbox",                    version = "ef8864bb42bf244f0295d1c5a403b27e3d139695" },
  { src = "https://github.com/nvim-telescope/telescope.nvim",      version = "40aedd8a68c78a656a10a8d62d80c54af59420fb" },
  { src = "https://github.com/mikavilpas/yazi.nvim",               version = "7fa3a7059a338678e0da0e4647a87c3e40871448" },
  { src = "https://github.com/sindrets/diffview.nvim",             version = "4516612fe98ff56ae0415a259ff6361a89419b0a" },
  { src = "https://github.com/lewis6991/gitsigns.nvim",            version = "8d79f2410c76e62b92e51c28c82e28c1c5a3daeb" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter",    version = "f603a2f4da48728f80257fb5fbb90145fd1dc173" },
})

require('config.options')
require('config.keymaps')
require('config.statusline')

if not vim.g.vscode then
  require('config.lsp')
  require('plugins.gruvbox')
  require('plugins.telescope')
  require('plugins.yazi')
  require('plugins.diffview')
  require('plugins.gitsigns')
  require('plugins.treesitter')
end
