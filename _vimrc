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
" Help came from:
" * Steve Losh - "Learn Vimscript the Hard Way"
" * Eric Andreychek's .vimrc
"
" Folding configuration
":set foldmethod=marker
" Edit and uncomment next line if you want non-default marker
":set foldmarker={{{,}}}
":syntax enable

behave mswin

set statusline=%f\ %=Current:\ %-4l\ Total:\ %-4L

cnoremap jk <c-c>
cnoremap <esc> <nop>
inoremap jk <esc>
inoremap <esc> <nop>
noremap : ;
noremap ; :

noremap z @a
noremap <F2> :set invnumber

":noremap <F3> a:.,$s/^/          /
noremap <F4> :close<CR>
noremap <F5> /TAGGY

noremap <F6> maF'r"f'r"`a
noremap <F7> yypkI#<ESC>j
noremap <C-A> <Home>
noremap <C-E> <End>

nnoremap <tab> I<tab><esc>
nnoremap <s-tab> ^i<bs><esc>

vnoremap <tab> >gv
vnoremap <s-tab> <gv

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

filetype plugin on

syntax on

"inoremap # X#

let mapleader = ','
noremap <silent> <leader>a :make<CR>
noremap <silent> <leader>b :!./%<CR>
noremap <silent> <leader>C kmxjd'aGpmy:.,$s/^#//<CR>'ydG'xp
noremap <silent> <leader>c kmxjd'aGpmy:.,$s/^/#/<CR>'ydG'xp
noremap <silent> <leader>d mxV'a<`x
noremap <silent> <leader>f mxV'a>`x
noremap <silent> <leader>p :retab<CR>:%s/\s\+$//<CR>
noremap <silent> <leader>o :set noautoindent<CR>:set nosmartindent<CR>
noremap <silent> <leader>q :close<CR>
noremap <silent> <leader>s :!sort<CR>
noremap <silent> <leader>t :!perl -MText::Autoformat -eautoformat<CR>

" note that in order for MYVIMRC to be set correctly, it MATTERS where you
" have put your vimrc file. Note in the following "system" vs "user":
" :version
" VIM - Vi IMproved 7.4 (2013 Aug 10, compiled Aug 10 2013 14:38:33)
" [...]
"  system vimrc file: "$VIM\vimrc"
"    user vimrc file: "$HOME\_vimrc"
noremap <silent> <leader>v :e $MYVIMRC<CR>

let g:vimwiki_list = [{'path': '~/vimwiki/', 'path_html': '~/public_html/'},
    \ {'path': 'd:\dropbox\other\wiki' }]

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

" These are all just playing around vim functions:
function DisplayName(name)
    echom "Hello! My name is:"
    echom a:name
endfunction

function Varg(...)
  " if called via :call Varg("a","b")
  " 2 (# of args)
  echom a:0
  " a (first arg)
  echom a:1
  " ['a', 'b'] (list of all args)
  echo a:000
endfunction

"inoremap <S-tab> <c-r>=InsertTabWrapper ("backward")<cr>
"inoremap <tab> <c-r>=InsertTabWrapper ("forward")<cr>

au GUIEnter * simalt ~x

