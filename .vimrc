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

hi Normal guibg=NONE ctermbg=NONE
map <C-n> :NERDTreeToggle<CR>
let g:cpp_member_variable_highlight = 1
let g:airline_theme='minimalist'
highlight LineNr ctermfg=darkgrey ctermbg=none 
highlight Visual ctermfg=darkgrey ctermbg=white guibg=Grey
