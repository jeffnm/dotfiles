"
" Plugins
"

" Install the plugin manager and the plugins
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Load the plugins
call plug#begin()
Plug 'elmcast/elm-vim'
Plug 'w0rp/ale'
Plug 'vim-syntastic/syntastic'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-surround'
Plug 'morhetz/gruvbox'
Plug 'scrooloose/nerdtree'
Plug 'airblade/vim-gitgutter'
Plug 'pangloss/vim-javascript'
Plug 'MaxMEllon/vim-jsx-pretty'
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
Plug 'elzr/vim-json'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'


Plug 'ryanoasis/vim-devicons'
call plug#end()

"
" Other configurations
"

if has('mouse_sgr')
    set ttymouse=sgr
endif

syntax on
"colorscheme desert
colorscheme gruvbox

set encoding=UTF-8
set nocompatible
set number 
set relativenumber
set autochdir " automatically set current directory to directory of last opened file
set showmatch           " highlight matching [{()}]
set mouse=a " enable mouse mode (scrolling, selection, etc)
set splitright
set splitbelow
set termguicolors
" Spaces & Tabs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set tabstop=2       " number of visual spaces per TAB
set softtabstop=2   " number of spaces in tab when editing
set expandtab       " tabs are spaces

" Show last command
set laststatus=2
set noerrorbells visualbell t_vb= " disable audible bell

" Search settings
set ignorecase
set smartcase
set incsearch
set hlsearch            " highlight matches

" Folding
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set foldenable          " enable folding
set foldlevelstart=10   " open most folds by default
set foldnestmax=10      " 10 nested fold max
" space open/closes folds
" nnoremap <space> za
set foldmethod=indent   " fold based on indent level

" Tab completion for files/buffers
set wildmode=longest,list
set wildmenu

" quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l



" colemak mod-dh adjustment
"
nnoremap n j
nnoremap e k
nnoremap k h
nnoremap i l
nnoremap j n
nnoremap l e
nnoremap h i

" toggle nerdtree with F6
nmap <F6> :NERDTreeToggle<CR>
" auto open nerdtree if no file is specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" auto close vim if nerdtree is the only thing still open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

if exists("g:loaded_webdevicons")
  call webdevicons#refresh()
endif
