"
" I know i got the bulk of this from someone else, who then in turn credited
" Eric Andreychek. Let me know if it's you and thanks! -David Bradford
"
" *** NOTE ***
"
" Sometimes settings mysteriously don't work, for example, after :set nobackup
" Settings still set to 'backup'.
" To figure out where this gets set
" :verbose set backup?
"
" Output is
"
" nobackup
"         Last set from C:\Program Files\Vim\vimrc
"
" Lots of help from Eric Andreychek's .vimrc
" Folding configuration
":set foldmethod=marker
" Edit and uncomment next line if you want non-default marker
":set foldmarker={{{,}}}
":syntax enable

map z @a
map <F2> :set invnumber

":map <F3> a:.,$s/^/          /
map <F4> :close<CR>
map <F5> /TAGGY

map <F6> maF'r"f'r"`a
map <F7> yypkI#<ESC>j
map <C-A> <Home>
map <C-E> <End>

nmap <tab> I<tab><esc>
nmap <s-tab> ^i<bs><esc>

vmap <tab> >gv
vmap <s-tab> <gv

iabbrev #!p #!/usr/bin/perl -w<CR><BS><CR>use strict;<CR><ESC>:filetype detect<CR>i

set autoindent
set backspace=2
set bg=light
set comments=b:#,:%,fb:-,n:>,n:)
set expandtab
set formatoptions=cqrt
set keywordprg=perldoc\ -f
set laststatus=2
set list
set listchars=tab:ωπ,trail:ά
set nobackup
set nocompatible
set nohlsearch
set noswapfile
set nowritebackup
set number
set ruler
set scrolloff=3
set shiftwidth=4
set showmatch
set ignorecase
set smartcase
set smartindent
set softtabstop=4
set t_vb=
set title
set tabstop=4
set ul=0
set viminfo=%,'50,\"100,:100,n~/.viminfo
set novisualbell
set whichwrap=<,>,h,l
set wildmenu
set wildmode=list:longest,full

syntax on

noremap <silent> ,a :make<CR>
noremap <silent> ,b :!./%<CR>
noremap <silent> ,C kmxjd'aGpmy:.,$s/^#//<CR>'ydG'xp
noremap <silent> ,c kmxjd'aGpmy:.,$s/^/#/<CR>'ydG'xp
noremap <silent> ,d mxV'a<`x
noremap <silent> ,f mxV'a>`x
noremap <silent> ,m :map<CR>
noremap <silent> ,p :retab<CR>:%s/\s\+$//<CR>
noremap <silent> ,q :q!<CR>
noremap <silent> ,r :rew!<CR>
noremap <silent> ,o :set noautoindent<CR>:set nosmartindent<CR>
noremap <silent> ,u :!perl -MText::Autoformat -eautoformat<CR>
noremap <silent> ,v :e $HOME/.vimrc<CR>
noremap <silent> ,w :w!<CR>
noremap <silent> ,z :wq!<CR>

"colorscheme darkblue
colorscheme elflord

" Mmmmm... tab completetion
function! InsertTabWrapper(direction)
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    elseif "backward" == a:direction
        return "\<c-p>"
    else
        return "\<c-n>"
    endif
endfunction

"inoremap <S-tab> <c-r>=InsertTabWrapper ("backward")<cr>
"inoremap <tab> <c-r>=InsertTabWrapper ("forward")<cr>

"au GUIEnter * simalt ~x

