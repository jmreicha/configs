"" Vundle config
set nocompatible
filetype off

"" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#rc()

"" let Vundle manage Vundle
Bundle 'gmarik/Vundle.vim'
"" GO tools
Bundle 'fatih/vim-go'
"" Color schemes
Bundle 'flazz/vim-colorschemes'
"" Terraform
Bundle 'markcornick/vim-terraform'
"" Git integration
Bundle 'tpope/vim-fugitive'
"" Show Git file changes
Bundle 'airblade/vim-gitgutter'
"" JSON highlighting
Bundle 'elzr/vim-json'
"" Nerdtree
Bundle 'scrooloose/nerdtree'
Bundle 'Xuyuanp/nerdtree-git-plugin'
Bundle 'jistr/vim-nerdtree-tabs'
"" Fuzzy file searching
Bundle 'kien/ctrlp.vim'
"" Keep track of parenths
Bundle 'luochen1990/rainbow'
"" Better status line
Bundle 'bling/vim-airline'
"" Whitespace highlighting
Bundle 'ntpeters/vim-better-whitespace'
"" Syntax highlighting
Bundle 'scrooloose/syntastic'
"" Dockerfile syntax highlighting
Bundle 'ekalinin/Dockerfile.vim'
"" Autocomplete
Bundle 'Valloric/YouCompleteMe'

filetype plugin indent on

"" Put swap files in swapfiles directory
set directory=$HOME/.vim/swapfiles//

"" Vim colorscheme
colorscheme xoria256

"" Correctly handle yml
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

"" Highlight lines over 80 characters
set textwidth=80
set colorcolumn=+1
"" No automatic line wrapping
set formatoptions-=t

"" Basics
set number
set showcmd
set cursorline

"" Syntax highlighting
syntax on

"" Searching
set ignorecase
set hlsearch
set incsearch

"" Yank to system clipboard
set clipboard=unnamed

"" Editing behavior
set tabstop=4
set smarttab
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent
set nowrap
set scrolloff=3
set visualbell
set whichwrap=b,s,h,l,<,>,[,]
set backspace=indent,eol,start

" Auto source vimrc on save
augroup reload_vimrc " {
    autocmd!
    autocmd BufWritePost $MYVIMRC source $MYVIMRC
augroup END " }

" Turn on rainbow parentheses
let g:rainbow_active = 1

" Syntastic statusline
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
" Sytnastic settings
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_loc_list_height=5
let g:syntastic_check_on_wq = 0
" Better symbols
let g:syntastic_error_symbol = 'XX'
let g:syntastic_warning_symbol = '!!'
" Automatically close location-list on quit
autocmd WinEnter * if &buftype ==# 'quickfix' && winnr('$') == 1 | quit | endif

" Turn on airline
set laststatus=2

" Filetype based auto indenting
filetype indent on

" Newline shortcut
nnoremap <S-J> o<Esc>

" Tab navigation shortcuts
nnoremap <C-j> gT
nnoremap <C-k> gt
nnoremap <C-Left> gT
nnoremap <C-Right> gt
nnoremap 1<cr> 1gt
nnoremap 2<cr> 2gt
nnoremap 3<cr> 3gt
nnoremap 4<cr> 4gt
nnoremap 5<cr> 5gt
nnoremap 6<cr> 6gt
nnoremap 7<cr> 7gt
nnoremap 8<cr> 8gt
nnoremap 9<cr> 9gt
nnoremap 0<cr> :tablast<cr>

" Turn off search highlight
nnoremap <CR> :noh<CR><CR>

" Change comment color
hi comment ctermfg=green

" Markdown higlighting
au BufNewFile,BufReadPost *.md set filetype=markdown
