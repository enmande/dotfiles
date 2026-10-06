-- Set to false to fall back to Vim's built-in indentation.
local use_treesitter_indent = true

require('nvim-treesitter').install({
  'typescript', 'tsx', 'javascript',
  'angular', 'html', 'css', 'scss',
  'c_sharp',
  'rust',
  'markdown', 'markdown_inline',
  'json',
})

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('Treesitter', { clear = true }),
  pattern = {
    'typescript', 'typescriptreact', 'javascript', 'javascriptreact',
    'htmlangular', 'html', 'css', 'scss', 'cs', 'rust', 'markdown', 'json',
  },
  callback = function(ev)
    if not pcall(vim.treesitter.start, ev.buf) then return end

    vim.wo[0][0].foldmethod = 'expr'
    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo[0][0].foldlevel = 99

    local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
    if use_treesitter_indent and vim.treesitter.query.get(lang, 'indents') then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
