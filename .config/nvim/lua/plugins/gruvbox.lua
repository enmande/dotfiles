return {
  "morhetz/gruvbox",
  lazy = false,
  priority = 1000,
  config = function()
    vim.g.gruvbox_contrast_dark = 'medium'
    vim.g.gruvbox_italic = 1
    vim.cmd([[colorscheme gruvbox]])
  end,
}
