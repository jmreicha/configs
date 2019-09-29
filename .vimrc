"" Vim Plugins
call plug#begin('~/.vim/plugged')

"" Highlighting

"" Terraform
Plug 'hashivim/vim-terraform'
"" JSON
Plug 'elzr/vim-json'
"" Ansible (Jinja templates)
Plug 'lepture/vim-jinja'
"" Whitespace
Plug 'ntpeters/vim-better-whitespace'
"" Syntax and linting
Plug 'dense-analysis/ale'
"" Dockerfile
Plug 'ekalinin/Dockerfile.vim'
"" Jsonnet
Plug 'google/vim-jsonnet'
"" Typescript
Plug 'leafgarland/typescript-vim'
"" Nginx
Plug 'chr4/nginx.vim'
"" Yaml
Plug 'mrk21/yaml-vim'

"" Git

"" Git integration
Plug 'tpope/vim-fugitive'
"" Show Git file changes
Plug 'airblade/vim-gitgutter'

"" Productivity

"" GO tools
Plug 'fatih/vim-go'
"" Color schemes
Plug 'flazz/vim-colorschemes'
"" Keep track of parenths
Plug 'luochen1990/rainbow'
"" Better status line
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'
"" Javascript tools
Plug 'othree/yajs.vim'
"" Hanldle more text objects
Plug 'wellle/targets.vim'
"" Markdown tools
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
"" Surround tools
Plug 'tpope/vim-surround'
"" Comment tools
Plug 'tpope/vim-commentary'
"" Search highlighting
Plug 'romainl/vim-cool'
"" Readline (bash) key bindings
Plug 'tpope/vim-rsi'
"" Indent highlighting (Only for cetain filetypes, e.g. yaml)
Plug 'Yggdroot/indentLine', {'for': 'yaml'}
"" Fuzzy file searching and FZF integration
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
"" Python code formatting
Plug 'ambv/black'
"" Better line highlighting
"Plug 'miyakogi/conoline.vim'
call plug#end()

" Filetype based auto indenting
filetype plugin indent on

"" Put swap files in swapfiles directory
set directory=$HOME/.vim/

"" Vim colorscheme
colorscheme ir_black

"" Correctly handle yml
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
"" Green indent
let g:indentLine_color_term = 40
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

"" Syntax highlighting
syntax on

"" Searching
set ignorecase
set hlsearch
set incsearch
hi Search ctermbg=LightGreen
hi Search ctermfg=Red

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

"" Misc settings
set laststatus=2
set t_Co=256
set wildmenu
" set wildmode=longest:list,full

"" Airline status settings
" let g:airline_powerline_fonts = 1
" if !exists('g:airline_symbols')
"   let g:airline_symbols = {}
" endif
" let g:airline_symbols.space = "\ua0"

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
" Terraform 0.11 has formatting issues so we disable for now
"let g:terraform_fmt_on_save = 1

" Turn on rainbow parentheses
let g:rainbow_active = 1

" jsonnet formatting
let g:jsonnet_fmt_options = ' -i -n 2 --string-style d --comment-style h '

" ALE settings
let g:ale_linters = {'python': ['pycodestyle', 'pylint']}

" Automatically format Python files on save
autocmd BufWritePre *.py execute ':Black'

" Automatically close location-list on quit
autocmd WinEnter * if &buftype ==# 'quickfix' && winnr('$') == 1 | quit | endif

nnoremap <silent> <C-p> :FZF<CR>

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

" Cursorcolumn settings
"set cursorcolumn
"highlight CursorColumn guibg=#303000 ctermbg=234

" Highlight empty spaces with dots and tabs with dashes
"set list listchars=tab:»-,trail:·,extends:»,precedes:«
"set list listchars=tab:❘-,trail:·,extends:»,precedes:«,nbsp:×

" Convert spaces to tabs when reading file
"autocmd! bufreadpost * set noexpandtab | retab! 4
" convert tabs to spaces before writing file
"autocmd! bufwritepre * set expandtab | retab! 4
" convert spaces to tabs after writing file (to show guides again)
"autocmd! bufwritepost * set noexpandtab | retab! 4

" Cursorline highlighting and settings
set cursorline
hi cursorline cterm=none term=none
autocmd WinEnter * setlocal cursorline
autocmd WinLeave * setlocal nocursorline
highlight CursorLine guibg=#303000 ctermbg=234

" Gitgutter colors - this seems to be an issue upgrading to vim8?
highlight clear SignColumn
highlight GitGutterAdd ctermfg=green
highlight GitGutterChange ctermfg=yellow
highlight GitGutterDelete ctermfg=red
highlight GitGutterChangeDelete ctermfg=yellow
