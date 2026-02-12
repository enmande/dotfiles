" Portable editing preferences
" Sourced by: Neovim, VSCode (vscode-neovim), JetBrains (IdeaVim)

let mapleader = " "
let maplocalleader = ","

set ignorecase
set smartcase
set incsearch
set showcmd
set showmode

" System clipboard
nnoremap <leader>y "+y
nnoremap <leader>Y "+Y
nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>y "+y
vnoremap <leader>Y "+Y
vnoremap <leader>p "+p
vnoremap <leader>P "+P

" Neovim-specific configuration
if has('nvim')
  lua require('config')
endif
