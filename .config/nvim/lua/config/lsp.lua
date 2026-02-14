-- LSP Configuration (native vim.lsp.config)

-- Static servers (cmd is constant)
vim.lsp.config.ts_ls = {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
}
vim.lsp.enable('ts_ls')

-- Angular LSP (cmd depends on project root)
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'typescript', 'html' },
  callback = function()
    local mono_root = vim.fs.root(0, { 'nx.json', '.git' }) 
    local global_modules = vim.fn.trim(vim.fn.system('npm root -g'))
    local probe = table.concat({ mono_root, global_modules }, ',')

    vim.lsp.start({
      name = 'angularls',
      cmd = { 'ngserver', '--stdio',
              '--tsProbeLocations', probe,
              '--ngProbeLocations', probe,
              '--forceStrictTemplates' },
      root_dir = root,
    })
  end,
})

-- LSP keymaps (buffer-local, set on attach)
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('LspKeymaps', { clear = true }),
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }

    -- Navigation
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'K', function()
	    vim.lsp.buf.hover({border = "rounded"})
    end, opts)

    -- Refactoring
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)

    -- Telescope LSP integration (lazy-loads Telescope via require)
    vim.keymap.set('n', '<leader>ds', function() require('telescope.builtin').lsp_document_symbols() end, opts)
    vim.keymap.set('n', '<leader>ws', function() require('telescope.builtin').lsp_workspace_symbols() end, opts)
  end,
})
