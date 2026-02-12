-- LSP Configuration (native vim.lsp.config)

local servers = {
  ts_ls = {
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
    root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
  },
  angularls = {
    cmd = { 'ngserver', '--stdio' },
    filetypes = { 'typescript', 'html' },
    root_markers = { 'angular.json' },
  },
}

for name, config in pairs(servers) do
  local executable = config.cmd[1]
  if vim.fn.executable(executable) == 0 then
    vim.notify('LSP server not found: ' .. executable, vim.log.levels.WARN)
  end
  vim.lsp.config[name] = config
end

-- Enable ts_ls globally
vim.lsp.enable('ts_ls')

-- Only enable angularls in Angular projects
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'typescript', 'html' },
  callback = function()
    if vim.fn.findfile('angular.json', '.;') ~= '' then
      vim.lsp.enable('angularls')
    end
  end,
})
