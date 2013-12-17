"" Basics
set nocompatible
set textwidth=80
set number

"" Syntax highlighting
syntax on

"" Searching
set ignorecase
set hlsearch
set incsearch

"" Editing behavior
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set nowrap

"" Change comment color
hi comment ctermfg=green

"" Word processing
func! WordProcessorMode()
        setlocal formatoptions=t1
        setlocal textwidth=140
        map j gj
        map k gk
        setlocal smartindent
        setlocal spell spelllang=en_us
        setlocal noexpandtab
        endfu
com! WP call WordProcessorMode()
