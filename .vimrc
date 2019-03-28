"" Vundle config
set nocompatible
filetype off

"" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#rc()

"" Let Vundle manage Vundle
Bundle 'gmarik/Vundle.vim'

"" Highlighting

"" Terraform
Bundle 'hashivim/vim-terraform'
"" JSON
Bundle 'elzr/vim-json'
"" Ansible
Bundle "lepture/vim-jinja"
"" Whitespace
Bundle 'ntpeters/vim-better-whitespace'
"" Syntax
Bundle 'scrooloose/syntastic'
"" Dockerfile
Bundle 'ekalinin/Dockerfile.vim'
"" Jsonnet
Bundle 'google/vim-jsonnet'
"" Typescript
Bundle 'leafgarland/typescript-vim'
"" Nginx
Bundle 'chr4/nginx.vim'

"" Git

"" Git integration
Bundle 'tpope/vim-fugitive'
"" Show Git file changes
Bundle 'airblade/vim-gitgutter'

"" Productivity

"" GO tools
Bundle 'fatih/vim-go'
"" Color schemes
Bundle 'flazz/vim-colorschemes'
"" Fuzzy file searching
Bundle 'kien/ctrlp.vim'
"" Keep track of parenths
Bundle 'luochen1990/rainbow'
"" Better status line
Bundle 'bling/vim-airline'
"" Javascript tools
Bundle 'othree/yajs.vim'
"" Hanldle more text objects
Bundle 'wellle/targets.vim'
"" Markdown tools
Bundle 'godlygeek/tabular'
Bundle 'plasticboy/vim-markdown'
"" Surround tools
Bundle 'tpope/vim-surround'
"" Readline (bash) key bindings
Bundle 'tpope/vim-rsi'
"" Python code formatting
"Bundle 'ambv/black'
"" Indent highlighting
Bundle 'Yggdroot/indentLine'

" Filetype based auto indenting
filetype plugin indent on

"" Put swap files in swapfiles directory
set directory=$HOME/.vim/

"" Vim colorscheme
colorscheme ir_black

"" Correctly handle yml
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
"let g:indent_guides_enable_on_vim_startup = 1

"" Handle nginx configs
autocmd BufNewFile,BufRead,BufReadPost *.conf set syntax=nginx
autocmd BufNewFile,BufRead,BufReadPost *.tmpl set syntax=nginx

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

" Markdown
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_auto_extension_ext = 'txt'
"let g:vim_markdown_folding_level = 3

" Terraform
let g:terraform_align=1
let g:terraform_fmt_on_save = 1

" Turn on rainbow parentheses
let g:rainbow_active = 1

" jsonnet formatting
let g:jsonnet_fmt_options = ' -i -n 2 --string-style d --comment-style h '

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

" Disable Python linting
let g:syntastic_python_checkers = []
"let g:syntastic_python_checkers = ['pyflakes']
"let g:syntastic_python_checkers = ['pylint']

" Javascript linting
"let g:syntastic_javascript_checkers = ['eslint']

" Automatically format Python files on save
autocmd BufWritePre *.py execute ':Black'

" Automatically close location-list on quit
autocmd WinEnter * if &buftype ==# 'quickfix' && winnr('$') == 1 | quit | endif

" Turn on airline
set laststatus=2

" Quick escape
inoremap jj <Esc>

" Newline shortcut
nnoremap <C-j> o<Esc>

" Insert a single character
nnoremap <C-i> i_<Esc>r

" Tab navigation shortcuts
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
"hi comment ctermfg=green

" Markdown higlighting
au BufNewFile,BufReadPost *.md set filetype=markdown
