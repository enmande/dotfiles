
let mapleader = " "

set ignorecase
set smartcase

" Wildmenu
set wildmenu
set wildmode=longest:full,full
set wildignorecase
set wildcharm=<Tab>
set showcmd
set showmode
set inccommand=split
set incsearch

" NORMAL
nnoremap <leader>h :help <C-r><C-w><CR>
nnoremap <leader>f :Files<CR>
nnoremap <leader>y "+y
nnoremap <leader>p "+p

" VISUAL
vnoremap <leader>y "+y
vnoremap <leader>p "+p

" COMMAND
" Show all matches for a partial :command (ask 'what can I say here?')
cnoremap <C-Space> <C-d>

" :grep => ripgrep
set grepprg=rg\ --vimgrep\ --smart-case
set grepformat=%f:%l:%c:%m
