syntax on set noerrorbells
set tabstop=4
filetype plugin indent on
set shiftwidth=4
set expandtab
set nu
set nowrap
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set backspace=indent,eol,start

call plug#begin('~/.vim/plugged')
Plug 'leafgarland/typescript-vim'
Plug 'mbbill/undotree'
Plug 'morhetz/gruvbox'
Plug 'jcherven/jummidark.vim'
Plug 'reedes/vim-colors-pencil'
Plug 'nightsense/snow'
Plug 'DrTom/fsharp-vim'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-fugitive'
Plug 'preservim/nerdtree'
Plug 'xuyuanp/nerdtree-git-plugin'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'rust-lang/rust.vim'
Plug 'dense-analysis/ale'
Plug 'sheerun/vim-polyglot'
call plug#end()

colorscheme jummidark
hi Normal guibg=NONE ctermbg=NONE
map <C-n> :NERDTreeToggle<CR>
let g:cpp_member_variable_highlight = 1
let g:airline_theme='minimalist'
highlight LineNr ctermfg=darkgrey ctermbg=none 
highlight Visual ctermfg=darkgrey ctermbg=white guibg=Grey
