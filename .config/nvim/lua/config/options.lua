-- vim.o.termguicolors = false
-- vim.o.background = 'dark'
vim.o.backspace = 'indent,eol,start'
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

-- Wildmenu
vim.o.wildmenu = true
vim.o.wildmode = 'longest:full,full'
vim.o.wildignorecase = true
vim.o.wildcharm = ('\t'):byte()
vim.o.completeopt = 'menu,menuone,noselect'
vim.o.inccommand = 'split'

-- Grep
vim.o.grepprg = 'rg --vimgrep --smart-case'
vim.o.grepformat = '%f:%l:%c:%m'
