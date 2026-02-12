let mapleader = " "
let maplocalleader = ","

if !exists('g:vscode')
  lua require('lsp')
  lua require('config.lazy')
endif

set ignorecase
set smartcase
set notermguicolors
set background=dark
set backspace=indent,eol,start

" Wildmenu
set wildmenu
set wildmode=longest:full,full
set wildignorecase
set wildcharm=<Tab>
set showcmd
set showmode
set completeopt=menu,menuone,noselect
set inccommand=split
set incsearch

" NORMAL
nnoremap <leader>h :help <C-r><C-w><CR>
"nnoremap <leader>f :Files<CR>
nnoremap <leader>y "+y
nnoremap <leader>Y "+Y
nnoremap <leader>p "+p
nnoremap <leader>P "+P
nnoremap <leader>q :call ToggleQuickfix()<CR>
function! ToggleQuickfix()
  for win in getwininfo()
    if win.quickfix
      cclose
      return
    endif
  endfor
  copen
endfunction

" VISUAL
vnoremap <leader>y "+y
vnoremap <leader>Y "+Y
vnoremap <leader>p "+p
vnoremap <leader>P "+P

" COMMAND
" Show all matches for a partial
cnoremap <C-Space> <C-d>

" TERMINAL
" Exit terminal-mode (explicit)
tnoremap <C-w><C-w> <C-\><C-n>
" Preserve <C-w> split nav
tnoremap <C-w> <C-\><C-n><C-w>
" From normal-mode in a terminal buffer, 'i' resumes terminal input
augroup TerminalComfort
  autocmd!
  autocmd TermOpen * nnoremap <buffer> i a
augroup END

" :grep => ripgrep
set grepprg=rg\ --vimgrep\ --smart-case
set grepformat=%f:%l:%c:%m

