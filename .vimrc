" Needed on some linux distros.
" see http://www.adamlowe.me/2009/12/vim-destroys-all-other-rails-editors.html
filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

syntax on
filetype plugin indent on

set nocompatible
set autoread

" Quickly edit/reload the vimrc file
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

" hide buffers instead of closing them
set hidden
set number

set clipboard+=unnamed  "OS X clipboard

set history=1000         " remember more commands and search history
set undolevels=1000      " use many muchos levels of undo
set wildignore=*.swp,*.bak,*.pyc,*.class
set title                " change the terminal's title
set visualbell           " don't beep

set nobackup
set noswapfile
set ruler                " show the cursor position all the time

set smartindent
set autoindent

set showmode      " show editing mode
set showcmd       " display incomplete commands
set incsearch     " do incremental searching
set hlsearch      " ???
:highlight clear Search
:highlight Search term=reverse ctermbg=22
set ignorecase    " ignore case when searching
set laststatus=2  " Always display the status line

set splitright
set splitbelow

set wildmenu      " make tab completion act more like bash
set wildmode=list:longest

set statusline=%F%m%r%h%w\ [TYPE=%Y]\ \ \ \ \ \ \ \ \ \ \ \ [POS=%2l,%2v][%p%%]\ \ \ \ \ \ \ \ \ \ \ \ [LEN=%L]
set laststatus=2

set switchbuf=useopen

if bufwinnr(1)
  map + <C-W>+
  map - <C-W>-
endif

" Quickly delete trailing spaces and tab characters turning the tabs into 4 spaces
function! ClearAllTrailingSpaces()
  %s/\s\+$//
  %s/\t/    /g
endfunction

" and map it to <Leader>cts
nmap <Leader>cts :call ClearAllTrailingSpaces()<CR>

" For when you forget to sudo.. Really Write the file.
cmap w!! w !sudo tee % >/dev/null

" Display extra whitespace
set list listchars=tab:»·,trail:·

iabbrev rdebug require 'ruby-debug'; Debugger.start; Debugger.settings[:autoeval] = 1; Debugger.settings[:autolist] = 1; debugger

autocmd FileType html setlocal shiftwidth=2 tabstop=2
autocmd FileType ruby,cucumber,haml setlocal expandtab shiftwidth=2 softtabstop=2
autocmd FileType javascript setlocal expandtab shiftwidth=2 softtabstop=2
autocmd FileType php setlocal shiftwidth=4 tabstop=4

"let mapleader=","
" map ,t :wa<cr>:!rspec -fd --color %<cr>

function! RunTests(filename)
" Write the file and run tests for the given filename
    :w
    :silent !echo;echo;echo;echo;echo
    exec ":!bundle exec rspec " . a:filename
endfunction

function! SetTestFile()
" Set the spec file that tests will be run for.
  let t:grb_test_file=@%
endfunction

function! SetTestLine(line)
  let t:grb_test_line=a:line
endfunction

function! RunTestFile(...)
  let in_spec_file = match(expand("%"), '_spec.rb$') != -1
  if a:0
    if in_spec_file
      call SetTestLine(a:1)
    endif
    if exists("t:grb_test_line")
      let command_suffix = t:grb_test_line
    else
      let command_suffix = ""
    endif
  else
    let command_suffix = ""
  endif
" Run the tests for the previously-marked file.
  if in_spec_file
    call SetTestFile()
  elseif !exists("t:grb_test_file")
    return
  end
  call RunTests(t:grb_test_file . command_suffix)
endfunction

function! RunNearestTest()
  let spec_line_number = line('.')
  call RunTestFile(":" . spec_line_number)
endfunction

" Run this file
" map <leader>t :call RunTestFile()<cr>
" Run only the example under the cursor
" map <leader>T :call RunNearestTest()<cr>
" Run cucumber wip
" map <leader>f :w\|:!cucumber -p wip<cr>
map ,t :call RunTestFile()<cr>
map ,T :call RunNearestTest()<cr>
map ,f :w\|:!cucumber -p wip<cr>


" multipurpose tab key (grb) - indent if at beginning of line, else complete
function! InsertTabWrapper()
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return "\<c-p>"
  endif
endfunction
inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-n>

" clear hls on return
function! MapCR()
  nnoremap <cr> :nohlsearch<cr>
endfunction
call MapCR()
