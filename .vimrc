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
"" Quotes/Parenths
""Bundle 'tpope/vim-surround'
"" Code completion
""Bundle 'Valloric/YouCompleteMe'

filetype plugin indent on

"" Vim colorscheme
colorscheme xoria256

"" Highlight lines over 80 characters
set textwidth=80
set colorcolumn=+1

"" Basics
set number
set showcmd
set cursorline
set paste

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

" Auto source vimrc on save
augroup reload_vimrc " {
    autocmd!
    autocmd BufWritePost $MYVIMRC source $MYVIMRC
augroup END " }

" Turn on rainbow parentheses
let g:rainbow_active = 1

" Turn on airline
set laststatus=2

" Close NerdTree if no files specified
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

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
