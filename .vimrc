
"PLUGINS
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.config/nvim/plugged')
if has('nvim')
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'neovim/nvim-lspconfig'
  Plug 'hrsh7th/nvim-compe'
endif
"Vim+tmux navigation
Plug 'christoomey/vim-tmux-navigator'
"Syntax highlighting
Plug 'hashivim/vim-terraform'
"Git tools
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
"Themes
Plug 'morhetz/gruvbox'
Plug 'lifepillar/vim-gruvbox8'
":SQLUFormatter to format SQL
Plug 'vim-scripts/SQLUtilities'
Plug 'vim-scripts/Align'
":DirDiff for directory diffing
Plug 'will133/vim-dirdiff'
"Browsing with -
Plug 'tpope/vim-vinegar'
"Shortcuts like ]q
Plug 'tpope/vim-unimpaired'
"FZF searching
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
"Browse history with :UndotreeToggle
"ysaW etc. for surrounding
Plug 'tpope/vim-surround'
"Task and wiki
Plug 'alok/notational-fzf-vim'
"Live previews of patterns and substitutions
Plug 'markonm/traces.vim'
"
Plug 'majutsushi/tagbar'
Plug 'ludovicchabant/vim-gutentags'
call plug#end()

let g:gutentags_cache_dir = "~/.nvim/tags"
let g:python3_host_prog = '/usr/local/bin/python3'

""BEHAVIOUR
syntax enable
set number
set hidden
set cursorline
let mapleader = "\<Space>"
"Open file at same line as when closed
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif

filetype indent plugin on
set backspace=indent,eol,start
set modeline
set tabstop=8
set shiftwidth=4
set softtabstop=4
set splitright

set mouse=r

set undofile
set undodir=~/.vim/undodir
set directory=~/.vim/swp
set backupdir=~/.vim/backup

""TOOLS
"Format JSON
command! -range -nargs=0 -bar JsonTool <line1>,<line2>!python -m json.tool

"in case sudo is forgotten
cmap w!! %!sudo tee > /dev/null %

"F5 adds a timestamp
map <F5> o<CR><ESC>:put =strftime('%c')<CR>==o

fun! RangerChooser()
  exec "silent !ranger --choosefile=/tmp/chosenfile " .           expand("%:p:h")
  if filereadable('/tmp/chosenfile')
    exec 'edit ' . system('cat /tmp/chosenfile')
    call system('rm /tmp/chosenfile')
  endif
  redraw!
endfun
map <Leader>x :call RangerChooser()<CR>

""VINEGAR
"nmap - <Plug>VinegarVerticalSplitUp
nmap - :Lexplore<CR>
let g:netrw_preview = 1
let g:netrw_winsize = 15

""GIT
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>ga :Gwrite<CR>
nnoremap <Leader>gc :Gcommit -v -q <CR>
nnoremap <Leader>gd :Gitdiff<CR>
nnoremap <Leader>go :Git checkout <Space>
nnoremap <Leader>gb :Git branch <Space>
nnoremap <Leader>gg :Ggrep <Space>
cnoreabbrev Gblame Gblame -w
autocmd BufWritePost * execute 'GitGutterAll'
autocmd Filetype gitcommit setlocal spell textwidth=72
hi def link gitcommitOverflow Error

""SEARCH
set ignorecase
set smartcase
set hlsearch
set incsearch
set wildmenu
set wildmode=longest,list,full

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)
nnoremap <Leader><Leader> :Rg<CR>
nnoremap <Leader>f :FZF<CR>
nnoremap <Leader>c :Commits<CR>
nnoremap <Leader>: :History:<CR>
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>t :Tags<CR>
"let g:fzf_commits_log_options = 'log1'
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

"Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)

if executable('rg')
    set grepprg=rg\ --vimgrep
    set grepformat=%f:%l:%c:%m
elseif executable('ag')
    set grepprg=ag\ --vimgrep
    set grepformat=%f:%l:%c:%m,%f:%l:%m
elseif executable('ack')
    set grepprg=ack\ --nogroup\ --nocolor\ --ignore-case\ --column
    set grepformat=%f:%l:%c:%m,%f:%l:%m
endif

" Project selector
function! s:projects_sink(lines)
  if len(a:lines) < 1
    return
  endif
  let dir = a:lines[0]
  call fzf#vim#files(dir, {})
  startinsert
endfunction

function! ProjectileProject()
  let projects = 'find ~/code ~/code/infrastructure-modules/* ~/code/*/modules ~/code/infrastructure-live -maxdepth 1 -mindepth 1 -type d -not -name .git'
  return fzf#run(fzf#wrap('projects', {'source': projects, 'sink*': function('s:projects_sink')}))
  "return fzf#run('files', {'source': projects, 'sink*': 'cd'})
endfunction 
nnoremap <Leader>p :call ProjectileProject()<CR>


function! EnteringBuffer()
    if filewritable(expand('%:p:h')) != 2
	return
    endif
    if &filetype == 'fugitive'
	return
    endif
    exe 'cd  %:p:h'
    let top_level = system("git rev-parse --show-toplevel")
    if v:shell_error == 0
	exe 'cd' top_level
    elseif v:shell_error == 128
	if expand('%:p:h') == expand('~') || match(expand('%:p:h'), expand('~/.config')) == 0
	    let g:gitgutter_git_args = '--git-dir=$HOME/.dotfiles/ --work-tree=$HOME' 
	endif
    elseif v:shell_error != 128
        echom v:shell_error
    endif
endfunction
autocmd BufEnter * call EnteringBuffer()
"set autochdir

""THEME
syntax on
set t_Co=256 "256 colours
set background=dark
set termguicolors
colorscheme gruvbox8
" Set for transparent terminals
"highlight Normal guibg=none ctermbg=none
set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<,nbsp:^
"set statusline=%F%m%r%h%w%=%y[%l,%c][%L][%{&ff}][%p%%]
set statusline=%<%f\ %h%m%r(%{FugitiveHead()})%{tagbar#currenttag('[%s]','')}%=%y[%l,%c][%L][%{&ff}][%p%%]
set signcolumn=yes

""NOTES
"Diary shortcut
nnoremap <Leader>w<Leader>w :vsplit ~/notes/diary/`date +\%Y-\%W`.md<CR>
"Search all Markdown headings
nnoremap <Leader>n :NV ^#<CR>
"TODO Shortcuts for searching todo.txt
nnoremap <Leader>a :vimgrep "(A)" ~/notes/todo.txt<CR>

let g:nv_default_extension = '.md'
let g:nv_search_paths = ['~/notes']
let g:nv_keymap = {
                    \ 'ctrl-s': 'split ',
                    \ 'ctrl-v': 'vertical split ',
                    \ 'ctrl-t': 'tabedit ',
                    \ }
let g:nv_create_note_key = 'ctrl-x'
let g:nv_create_note_window = 'vertical split'
let g:nv_show_preview = 1
let g:nv_wrap_preview_text = 0
let g:nv_preview_width = '40%'
let g:nv_preview_direction = 'right'
let g:nv_use_short_pathnames = 1
let g:nv_expect_keys = []

au FileType python setlocal formatprg=black\ -l\ 120\ --quiet\ -

""LATEX
let g:tex_flavor='latex'
let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_CompileRule_pdf = 'latexmk -pdf -pvc $*'
set iskeyword+=:
autocmd FileType tex setlocal makeprg=pdflatex\ --shell-escape\ '%'


""ANSIBLE
autocmd BufRead,BufNewFile *.yml setlocal filetype=ansible foldmethod=indent
set foldlevelstart=99


""TERRAFORM TERRAGRUNT
"Only works when in the infrastructure-live root
command! Terragrunt vsplit | term cd %:p:h && aws-vault exec '%:s?/.*??' -- terragrunt plan
command! TerragruntApply vsplit | term cd %:p:h && aws-vault exec '%:s?/.*??' -- terragrunt apply
command! -range TFLocalModules <line1>,<line2>s^\vsource.*/([a-zA-Z1-9_-]+)\.git//([a-zA-Z1-9/-]+)\?ref=.*^source = "/Users/dancorne/code/\1//\2"^e | norm!``
command! -range -nargs=1 TFModuleVersion <line1>,<line2>s^\v(source.*)\?ref=.*^\1?ref=<args>"^e | norm!``
command! AtlantisPlan :execute "!gh pr view --web | Gpush | sleep 5 | \!gh run-plan"<CR>
