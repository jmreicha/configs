"" Plugins

set nocompatible

call plug#begin('~/.vim/plugged')

" Language detection and support
Plug 'sheerun/vim-polyglot'
" Whitespace
Plug 'ntpeters/vim-better-whitespace'
" Syntax and linting
Plug 'dense-analysis/ale'
Plug 'z0mbix/vim-shfmt'
" Colors
Plug 'lilydjwg/colorizer'
" Git integration
Plug 'tpope/vim-fugitive'
" Show Git file changes
Plug 'airblade/vim-gitgutter'
" Color schemes
Plug 'flazz/vim-colorschemes'
Plug 'danilo-augusto/vim-afterglow'
Plug 'morhetz/gruvbox'
Plug 'jacoborus/tender.vim'
" Keep track of parenths
Plug 'luochen1990/rainbow'
" Better status line
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" Javascript tools
Plug 'othree/yajs.vim'
" Hanldle more text objects
Plug 'wellle/targets.vim'
" Markdown tools
Plug 'godlygeek/tabular'
" Surround tools
Plug 'tpope/vim-surround'
" Comment tools
Plug 'tpope/vim-commentary'
" Repeat with plugins
Plug 'tpope/vim-repeat'
" Search highlighting
Plug 'romainl/vim-cool'
" Readline (bash) key bindings
Plug 'tpope/vim-rsi'
" Indent highlighting (Only for cetain filetypes, e.g. yaml)
Plug 'Yggdroot/indentLine', {'for': 'yaml'}
" Fuzzy file searching and FZF integration
" Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" Code completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Better motions
Plug 'jeetsukumaran/vim-indentwise'
" Plug 'unblevable/quick-scope'
Plug 'justinmk/vim-sneak'
Plug 'easymotion/vim-easymotion'
Plug 'bkad/CamelCaseMotion'
call plug#end()

" Filetype based auto indenting
filetype plugin indent on

" Put swap files in swapfiles directory
set directory=$HOME/.vim/

"" Colorscheme

if has("termguicolors")
    set termguicolors
endif

" colorscheme ir_black
" colorscheme afterglow
" colorscheme iceberg
" colorscheme gruvbox
silent! colorscheme tender

" Correctly handle yml
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" Green indent
let g:indentLine_color_term = 40
"let g:indent_guides_enable_on_vim_startup = 1

" No automatic line wrapping
set formatoptions-=t

" Misc settings
set number
set showcmd
set laststatus=2
set t_Co=256
set wildmenu
" set wildmode=longest:list,full

" Syntax highlighting
syntax on

" Mouse support
set mouse=a

" Highlight lines over 80 characters
set textwidth=80
set colorcolumn=+1
hi ColorColumn ctermbg=76 guibg=#f43753

" Searching
set ignorecase
set hlsearch
set incsearch
" hi Search ctermbg=LightGreen
" hi Search ctermfg=Red

" Yank to system clipboard
set clipboard=unnamed

" Editing behavior
set tabstop=4
set smarttab
set softtabstop=4
set shiftwidth=4
set shiftround
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

" Highlight whitespace
let g:better_whitespace_enabled=1

" Terraform
let g:terraform_align=1
let g:terraform_fmt_on_save = 1
" HCL formatting/highlighting
autocmd BufRead,BufNewFile *.hcl set filetype=terraform
autocmd BufWritePre *.hcl call terraform#fmt()
" au! BufNewFile,BufRead *.hcl set filetype=terraform syntax=terraform

" Run GO imports on file save
let g:go_fmt_command = "goimports"
" Disable double completion with vim-go/coc
let g:go_code_completion_enabled = 0
" Disable vim-go :GoDef short cut (gd). This is handled by LanguageClient [LC]
let g:go_def_mapping_enabled = 0
" Show type info in statusbar
" let g:go_auto_type_info = 1

" Turn on rainbow parentheses
let g:rainbow_active = 1

" jsonnet formatting
let g:jsonnet_fmt_options = ' -i -n 2 --string-style d --comment-style h '

" shfmt
let g:shfmt_extra_args = '-i 4'
let g:shfmt_fmt_on_save = 1

"" ALE

" Use CoC in favor of ale lsps
let g:ale_disable_lsp = 1

" Look and feel
let g:ale_virtualtext_cursor = 0
let g:ale_echo_msg_format = '[%linter%][%severity%](%code%) %s'
let g:ale_sign_error = '✘'
let g:ale_sign_warning = '⚠'
highlight ALEErrorSign ctermbg=NONE ctermfg=red
highlight ALEWarningSign ctermbg=NONE ctermfg=yellow

" Linters
" let g:ale_linters = {'python': ['black', 'flake8', 'pycodestyle', 'pylint']}
let g:ale_linters = {
    \ 'docker': ['hadolint'],
    \ 'go': ['golangci-lint'],
    \ 'python': ['flake8', 'pylint'],
    \ 'yaml': ['yamllint']
    \ }

" Fixers
let b:ale_fixers = {
    \ 'json': ['fixjson'],
    \ 'python': ['black', 'isort'],
    \ '*': ['remove_trailing_lines', 'trim_whitespace']
    \ }
" let b:ale_fixers = {'python': ['isort']}

" let g:ale_lint_on_text_changed = 'never'
" let g:ale_lint_on_enter = 0

" Ignore lines over 80 chars
let g:ale_python_flake8_options = '--ignore=E501'
let g:ale_sh_bashate_options = '-i E006'

" Switch this setting to 0 to disable fixers
let g:ale_fix_on_save = 1

" Automatically close location-list on quit
autocmd WinEnter * if &buftype ==# 'quickfix' && winnr('$') == 1 | quit | endif

"" Shortcuts

" Split lines
nnoremap S :keeppatterns substitute/\s*\%#\s*/\r/e <bar> normal! ==<CR>
" FZF
nnoremap <silent> <C-p> :FZF<CR>
" Newline
nnoremap <C-j> o<Esc>
" Turn off search highlight
nnoremap <CR> :noh<CR><CR>
" Tab navigation
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
" Insert a single character
"nnoremap <C-i> i_<Esc>r

"" Markdown

" set list
" Spellcheck for markdown
" autocmd BufNewFile,BufRead,BufReadPost *.md setlocal spell
" Markdown higlighting
au BufNewFile,BufReadPost *.md set filetype=markdown
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_auto_extension_ext = 'txt'

"" Folding
set foldmethod=indent
set nofoldenable
set foldlevel=2

"" Misc

" Turn on cursorline highlighting
set cursorline
" hi cursorline cterm=none term=none
" autocmd WinEnter * setlocal cursorline
" autocmd WinLeave * setlocal nocursorline
" highlight CursorLine guibg=#303000 ctermbg=234

" Gitgutter colors - this seems to be an issue upgrading to vim8?
highlight clear SignColumn
highlight GitGutterAdd ctermfg=green
highlight GitGutterChange ctermfg=yellow
highlight GitGutterDelete ctermfg=red
highlight GitGutterChangeDelete ctermfg=yellow

" Airline status settings
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.space = "\ua0"

"" COC settings

" Set internal encoding of vim, not needed on neovim, since coc.nvim using some
" unicode characters in the file autoload/float.vim
set encoding=utf-8

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("nvim-0.5.0") || has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=yes
endif

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
