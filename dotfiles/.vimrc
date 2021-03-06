" Leader
let mapleader = " "

set backspace=2   " Backspace deletes like most programs in insert mode
set nobackup
set nowritebackup
set noswapfile    " http://robots.thoughtbot.com/post/18739402579/global-gitignore#comment-458413287
set history=50
set ruler         " show the cursor position all the time
set showcmd       " display incomplete commands
set incsearch     " do incremental searching
set laststatus=2  " Always display the status line
set autowrite     " Automatically :write before running commands

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
  syntax on
endif

if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

filetype plugin indent on

augroup vimrcEx
  autocmd!

  " When editing a file, always jump to the last known cursor position.
  " Don't do it for commit messages, when the position is invalid, or when
  " inside an event handler (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " Set syntax highlighting for specific file types
  autocmd BufRead,BufNewFile Appraisals set filetype=ruby
  autocmd BufRead,BufNewFile *.md set filetype=markdown
  autocmd BufRead,BufNewFile .{jscs,jshint,eslint}rc set filetype=json
  autocmd BufRead,BufNewFile *.{js,jsx} set suffixesadd+=.js,.jsx
augroup END

" When the type of shell script is /bin/sh, assume a POSIX-compatible
" shell for syntax highlighting purposes.
let g:is_posix = 1

" Softtabs, 2 spaces
set tabstop=2
set shiftwidth=2
set shiftround
set expandtab

" Display extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·

" Use one space, not two, after punctuation.
set nojoinspaces

" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag -Q -l --nocolor --hidden -g "" %s'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0

  if !exists(":Ag")
    command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
    nnoremap \ :Ag<SPACE>
  endif
endif

augroup quickfix
  autocmd!
  autocmd QuickFixCmdPost [^l]* cwindow
  autocmd QuickFixCmdPost l*    lwindow

  nnoremap [q :cprev<cr>
  nnoremap ]q :cnext<cr>
augroup END

" Make it obvious where 80 characters is
set textwidth=80
set colorcolumn=+1

" Numbers
set number
set numberwidth=5

" Tab completion
" will insert tab at beginning of line,
" will use completion if not at beginning
set wildmode=list:longest,list:full
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <Tab> <c-r>=InsertTabWrapper()<cr>
inoremap <S-Tab> <c-n>

" Switch between the last two files
nnoremap <leader><leader> <c-^>

" Get off my lawn
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

" vim-test mappings
nnoremap <silent> <Leader>t :TestFile<CR>
nnoremap <silent> <Leader>s :TestNearest<CR>
nnoremap <silent> <Leader>l :TestLast<CR>
nnoremap <silent> <Leader>a :TestSuite<CR>
nnoremap <silent> <leader>gt :TestVisit<CR>

" Run commands that require an interactive shell
nnoremap <Leader>r :RunInInteractiveShell<space>

" Treat <li> and <p> tags like the block tags they are
let g:html_indent_tags = 'li\|p'

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" configure syntastic syntax checking to check on open as well as save
" let g:syntastic_check_on_open=0
" let g:syntastic_html_tidy_ignore_errors=[" proprietary attribute \"ng-"]
" let g:syntastic_eruby_ruby_quiet_messages = {"regex": "possibly useless use of a variable in void context"}
" 
" let g:syntastic_javascript_checkers = ['eslint']
" let g:syntastic_javascript_eslint_exe = '$(npm bin)/eslint'

" let g:syntastic_error_symbol = '❌'
" let g:syntastic_style_error_symbol = '⁉️'
" let g:syntastic_warning_symbol = '⚠️'
" let g:syntastic_style_warning_symbol = '💩'
" let g:syntastic_error_symbol = 'X'
" let g:syntastic_style_error_symbol = 'x'
" let g:syntastic_warning_symbol = '?'
" let g:syntastic_style_warning_symbol = '?'

let g:ale_fix_on_save = 1
let g:ale_linters = { 
\'javascript': ['flow', 'eslint'],
\}
let g:ale_fixers = { 'javascript': ['prettier'] }

" Set spellfile to location that is guaranteed to exist, can be symlinked to
" Dropbox or kept in Git and managed outside of thoughtbot/dotfiles using rcm.
set spellfile=$HOME/.vim-spell-en.utf-8.add

" Autocomplete with dictionary words when spell check is on
set complete+=kspell

" Always use vertical diffs
" set diffopt+=vertical

" ▲ ---- from thoughtbot/dotfiles
" ▼ ---- personal config

syntax enable

" for vim 8
set t_Co=256
if (has("termguicolors"))
  set termguicolors
endif

colorscheme OceanicNext
" set background dark
let g:airline_theme='oceanicnext'


" thank you http://statico.github.io/vim.html
" wrapped lines behave like normal lines
set nowrap
nmap j gj
nmap k gk

nmap <Leader>n :NERDTreeToggle<CR>

" cmd+s to save
" 
" nnoremap <silent> <C-S> :<C-u>Update<CR>
" inoremap <c-s> <c-o>:Update<CR>
nnoremap <silent> <C-S> :w<CR>
inoremap <c-s> <c-o>:w<CR>
vmap <C-s> <esc>:w<CR>gv


map <M-s> :w<kEnter> "Works in normal mode, must press Esc first"
let g:airline_powerline_fonts = 1
" function! isBattery()
"   let value = system("$(pmset -g ps | head -1) =~ \"Battery Power\")
"   echo "value " . value
"   return value
" endfunction
" 
" if (isBattery()) {
"   let g:ale_lint_on_text_changed = 'never'
"   " if you don't want linters to run on opening a file
"   let g:ale_lint_on_enter = 0
" }

set hidden
" if has('nvim')
"  tnoremap <Esc> <C-\><C-n>
"  let g:LanguageClient_serverCommands = {
"  \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
"  \ 'reason': ['~/bin/reason-language-server'],
"  \ 'ocaml': ['ocaml-language-server', '--stdio'],
"  \ 'javascript': ['flow', 'lsp', '--from', './node_modules/.bin'],
"  \ 'javascript.jsx': ['flow', 'lsp', '--from', './node_modules/.bin'],
"  \ 'purescript': ['purescript-language-server', '--stdio', '--config', '{}']
"  \}
"  " \ 'typescript': ['typescript-language-server', '--stdio']
"  let g:LanguageClient_selectionUI = "fzf"
"  let g:LanguageClient_diagnosticsList = "Location"
"  let g:LanguageClient_loggingLevel = 'DEBUG'
"  let g:LanguageClient_rootMarkers = {
"    \ 'javascript': ['.flowconfig'],
"    \ 'typescript': ['tsconfig.json'],
"  }
"
"  nnoremap <silent> gd :call LanguageClient_textDocument_definition()<cr>
"  nnoremap <silent> gp :call LanguageClient_textDocument_formatting()<cr>
"  nnoremap <silent> <cr> :call LanguageClient_textDocument_hover()<cr>
" endif


" ======= coc settings
set updatetime=300
set shortmess+=c
" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> <cr> <Plug>(coc-type-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1, <bang>0)
set grepprg=rg\ --vimgrep

""" FocusMode
function! ToggleFocusMode()
  if (&foldcolumn != 12)
    set laststatus=0
    set numberwidth=10
    set foldcolumn=12
    set noruler
    hi FoldColumn ctermbg=none
    hi LineNr ctermfg=0 ctermbg=none
    hi NonText ctermfg=0
  else
    set laststatus=2
    set numberwidth=4
    set foldcolumn=0
    set ruler
    execute 'colorscheme ' . g:colors_name
  endif
endfunc
nnoremap <F1> :call ToggleFocusMode()<cr>

let g:sexp_enable_insert_mode_mappings = 0
let g:vimwiki_list = [{'path': '~/projects/_life',
                      \ 'syntax': 'markdown', 'ext': '.md'}]

command! -nargs=0 Prettier :CocCommand prettier.formatFile
autocmd BufNew,BufEnter *.md execute "silent! CocDisable"
autocmd BufLeave *.md execute "silent! CocEnable"
