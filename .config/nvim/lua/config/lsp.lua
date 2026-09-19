-- LSP Configuration (native vim.lsp.config)

-- Static servers (cmd is constant)
vim.lsp.config.ts_ls = {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
}
vim.lsp.enable('ts_ls')

-- Roslyn (C#) via the `roslyn-language-server` dotnet tool
local roslyn_log_dir = vim.fn.stdpath('cache') .. '/roslyn-ls'
vim.fn.mkdir(roslyn_log_dir, 'p')

vim.lsp.config.roslyn_ls = {
  cmd = {
    'roslyn-language-server',
    '--logLevel=Information',
    '--extensionLogDirectory=' .. roslyn_log_dir,
    '--stdio',
  },
  filetypes = { 'cs', 'cshtml' },
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, function(name)
      return name:match('%.sln[x]?$') ~= nil
    end) or vim.fs.root(bufnr, function(name)
      return name:match('%.csproj$') ~= nil
    end)
    on_dir(root)
  end,
  -- roslyn-language-server doesn't auto-discover projects from workspace
  -- folders; it needs an explicit solution/project handshake after init,
  -- otherwise it only analyzes whatever buffer is open.
  on_init = function(client)
    local root_dir = client.config.root_dir
    if not root_dir then
      return
    end

    for entry, kind in vim.fs.dir(root_dir) do
      if kind == 'file' and (vim.endswith(entry, '.sln') or vim.endswith(entry, '.slnx')) then
        client:notify('solution/open', { solution = vim.uri_from_fname(vim.fs.joinpath(root_dir, entry)) })
        return
      end
    end

    local csproj_files = {}
    for entry, kind in vim.fs.dir(root_dir) do
      if kind == 'file' and vim.endswith(entry, '.csproj') then
        table.insert(csproj_files, vim.fs.joinpath(root_dir, entry))
      end
    end

    if #csproj_files > 0 then
      client:notify('project/open', {
        projects = vim.tbl_map(vim.uri_from_fname, csproj_files),
      })
    end
  end,
  handlers = {
    -- Buffers opened before the solution/project load above finishes get
    -- diagnosed against an empty workspace (e.g. every `using` flagged as
    -- unnecessary). Roslyn doesn't advertise diagnosticProvider, so nothing
    -- re-pulls diagnostics once loading completes -- do it ourselves.
    ['window/logMessage'] = function(err, result, ctx, config)
      vim.lsp.handlers['window/logMessage'](err, result, ctx, config)
      if result and result.message and result.message:find('Completed (re)load of all projects', 1, true) then
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if client then
          for bufnr in pairs(client.attached_buffers) do
            vim.lsp.buf_request(bufnr, 'textDocument/diagnostic', {
              textDocument = vim.lsp.util.make_text_document_params(bufnr),
            })
          end
        end
      end
    end,
  },
}
vim.lsp.enable('roslyn_ls')

-- Angular LSP (cmd depends on project root)
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'typescript', 'html' },
  callback = function()
    local root = vim.fs.root(0, { 'angular.json', 'nx.json' })
    if not root then return end

    local probe = root .. ',' .. vim.fn.trim(vim.fn.system('npm root -g'))

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
