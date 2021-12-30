set nocompatible              " be iMproved, required
filetype off                  " required

" ==================================================================================================
" Env management
" ==================================================================================================
set rtp+=~/.fzf

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

" ==================================================================================================
" Plugin management
" ==================================================================================================
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Fuzzy search
" Plugin 'kien/ctrlp.vim'
Plugin 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plugin 'junegunn/fzf.vim'

" Autocompletion engine
Plugin 'Valloric/YouCompleteMe'

" Switch between header and cc file
Bundle 'vim-scripts/a.vim'

" Toggle comments
Bundle 'scrooloose/nerdcommenter'

" File directory pane
Bundle 'scrooloose/nerdtree'

" Airline (status/tabline)
Plugin 'vim-airline/vim-airline'

" Git
Plugin 'tpope/vim-fugitive'

" Indicate current version control diff
Plugin 'mhinz/vim-signify'

" Color schemes
Plugin 'morhetz/gruvbox'
Plugin 'chriskempson/base16-vim'

" djinni syntax highlighting
Plugin 'r0mai/vim-djinni'

" kotlin syntax highlighting
Plugin 'udalov/kotlin-vim'

" swift syntax highlighting
Plugin 'keith/swift.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" ==================================================================================================
" General text editor behavior
" ==================================================================================================
" Do not create swap file
set noswapfile

" Have Vim jump to the last position when reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
      \| exe "normal! g'\"" | endif
      endif

" Have Vim maintain undo history between sessions
set undofile "
set undodir=~/.vim/undodir

set number    " turn on line numbers
set expandtab " convert tabs to spaces
set smarttab  " insert and delete indent correctly

set shiftwidth=4  " tab size
set softtabstop=4 " tab size
set tabstop=4     " tab size

" set format options (default tcq) see http://vimdoc.sourceforge.net/htmldoc/change.html#fo-table
set fo-=t " don't auto-wrap text

" Change completion menu behavior
set completeopt=menu,menuone

" Indentation
set autoindent
set nosmartindent
set nocindent

" Better searching
set ignorecase
set smartcase
set incsearch
set hlsearch

" Backspace
set backspace=indent,eol,start

" yank selection to system clipboard (from http://stackoverflow.com/a/11489440/53997)
" Note that on linux:
"  - register "* maps to XA_PRIMARY (e.g. mouse selection buffer clipboard)
"  - register "+ maps to XA_SECONDARY (e.g. ctrl+c/ctrl+v clipboard)
nnoremap <leader><y> :normal! "+y<cr>
nnoremap <leader><p> :normal! "+p<cr>

" Toggle between paste and no-paste modes

" Tab navigation
map <C-t><up> :tabr<cr>
map <C-t><down> :tabl<cr>
map <C-t><left> :tabp<cr>
map <C-t><right> :tabn<cr>

" FZF shortcuts
nnoremap <c-@> :Files<cr>
nnoremap <c-p> :GFiles<cr>

" Search helpers
" Search for word under cursor
nnoremap <expr> <c-?> ':RG '.expand('<cword>').'<cr>'
" Search for yanked text
nnoremap <expr> <leader>? ':RG '.expand('<c-r>"').'<cr>'

nnoremap <leader><bar> :vsp<cr>
" Function Keys ---------------------------------------------------------------
nnoremap <F1> :YcmCompleter GetDoc<cr>
nnoremap <F2> :YcmCompleter GetType<cr>
nnoremap <F3> :YcmCompleter GoTo<cr>
nnoremap <F4> :YcmCompleter GoToSymbol

nnoremap <F5> :YcmForceCompileAndDiagnostics<cr>
nnoremap <F6> :YcmDiags<cr>
nnoremap <F7> :YcmShowDetailedDiagnostic<cr>
nnoremap <F8> :YcmCompleter FixIt<cr>

nnoremap <F9> :YcmCompleter RefactorRename
" nnoremap <F10>
" F11 is full screen
" nnoremap <F12>

" <LEADER> + Function keys ---------------------------------------------------
nnoremap <leader><F1> :Buffers<cr>
set pastetoggle=<leader><F2>
nnoremap <leader><F3> :set number!<cr> :SignifyToggle<cr>
nnoremap <leader><F4> :!./skyrun bin code_format<cr> :silent! bufdo e<cr> 
nnoremap <leader><F5> :source $MYVIMRC<cr>
" nnoremap <leader><F6>
" nnoremap <leader><F7>
" nnoremap <leader><F8>
" nnoremap <leader><F9>
" nnoremap <leader><F10>
" F11 is full screen
" nnoremap <leader><F12>
" ==================================================================================================
" Syntax highlighting
" ==================================================================================================
syntax enable

" set markdown filetypes
autocmd BufNewFile,BufFilePre,BufRead *.md set filetype=markdown

" set cpp filetypes
autocmd BufNewFile,BufFilePre,BufRead *.cc set filetype=cpp

" set java filetypes
autocmd BufNewFile,BufFilePre,BufRead *.java set filetype=java

" set python filetypes
autocmd BufNewFile,BufFilePre,BufRead *.py set filetype=python

" set djinni filetypes
autocmd BufNewFile,BufFilePre,BufRead *.djinni set filetype=djinni

" set kotlin filetypes
autocmd BufNewFile,BufFilePre,BufRead *.kt set filetype=kotlin

" set swift filetypes
autocmd BufNewFile,BufFilePre,BufRead *.swift set filetype=swift


autocmd BufNewFile,BufFilePre,BufRead,FileType *.vimrc setlocal shiftwidth=2 softtabstop=2 tabstop=2 textwidth=100

" ==================================================================================================
" Language specific editor behavior
" ==================================================================================================
" set tab size to 2 for .h, .cc files
autocmd FileType cpp setlocal shiftwidth=2 softtabstop=2 tabstop=2
autocmd FileType tex setlocal shiftwidth=2 softtabstop=2 tabstop=2
autocmd FileType java setlocal shiftwidth=2 softtabstop=2 tabstop=2
autocmd FileType python setlocal shiftwidth=4 softtabstop=4 tabstop=4

" set wrap size for just programming files
autocmd FileType c,cpp,java,python set textwidth=100 " set hard wrap width

autocmd FileType c,cc,cpp,objc,*.mm call SetupForCLang()


" ==================================================================================================
" Visual Bell
" ==================================================================================================
set visualbell t_vb= " turn off error beep/flash
set novisualbell " turn off visual bell

" ==================================================================================================
" Mouse
" ==================================================================================================
" Enable mouse control
set mouse=a

" ==================================================================================================
" FZF Configuration
" ==================================================================================================
" VSCode like search
function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case
              \ -g "*.{djinni,proto,mm,m,lcm,cc,h,swift,py,java,kt,cmake}"
              \ -g "!build/*"
              \ -g "!third_party_modules/*"
              \ -g "!third_party/*"
              \ -g "!bazel-out/*"
              \ -g "!*/node_modules/*"
              \ -- %s || true
              \'

  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

function! SkyRipgrepFzf( ... )
  " Usage:
  "   SkyRipgrepFzf([-f|-Nf file_extensions] [-d|Nd directories] [-p preset_name] [-n] query)
  "
  " Passes in some filtering options for rg, note that all options must come before the query.
  " Anything that is not parsed as an option (and potential following argument).
  "
  " Additionally, arguments that can 'be a list' are comma delimited.
  "
  " An example using the RG command I've set up below:
  "     :RG -f cc,lcm -d mobile/shared/mvvm,infrastructure/ar_video_shaders prism_t
  "
  " Options:
  "  --) Everything after this flag is considered part of the query. Useful if part of your query
  "      would have been interpreted as a flag
  "  -f) Specifically search within the filetypes listed in the next argument.
  "      For example, ':RG -f cc,h,lcm <QUERY>' will only search in *.cc *.h and *.lcm files
  "      Can be specified multiple times, for instance ':RG -f cc -f h -f lcm <QUERY>'
  "  -Nf) Specifically ignore filetypes listed in the next argument. Works like '-f'
  "  -d) Specifically search within the directories listed in the next argument.
  "      For example, ":RG -d mobile/shared/appcore,mobile/shared/mvvm will only look within
  "      those relative directories.
  "      Can also be specified multiple times. Note that you need to pass in a directory without the
  "      trailing slash... Maybe I should check for it and remove it. TBD
  "  -Nf) Specifically ignore directories listed in the next argument. Works like '-d'
  "  -p) Merge with preset. TODO, but the idea would be to set up constant 'filetype' and
  "      'directory' includes/ignores that merge with the provided preset name. For example, if we
  "      said ':RG -p ios' I would want it to auto-specify the 'mobile/ios' and swift,mm,m
  "      filetypes, unless specifically specified otherwise through other flags
  "
  " Current Limitations:
  "  - Would love to have tab-completion for directory searching
  "
  "  - We don't do any smart 'understanding' of filters. Putting a directory/filetype in both ignored
  "    and included will be excluded, regardless of ordering
  "
  "  - Setting a preset value right now will remove default search filtering.
  "
  "  - Can't change the filtering parameters once FZF's popup comes up
  "
  "  - Upon closer inspection, -d and -Nd are very close just generic regex patterns. Should set up
  "    an option for generic regex and a 'directories' flag. Maybe the main difference is how
  "    autocomplete will work with it.
  "
  "  - My vimscript is bad and it should feel bad. Lots of repeated code because I don't know a
  "    better way at the moment
  "=================================================================================================

  " In these dicts:
  " - if an entry has a value of 1, it is specifically included in the globing options
  " - if an entry has a value of 0, it is specifically ignored in the globing options
  let filetypes = {}
  let directories = {}
  let preset = ''
  let query=''
  let query_started=0

  let num_args = len(a:000)
  let curr_idx = 0
  while curr_idx < num_args
    let arg = a:000[curr_idx]
    if (!query_started)
        if (arg == '--') " Ignore all subsequent possible flags
            echom "Ignoring all future flags"
            let query_started = 1
            let curr_idx = curr_idx + 1
            continue " Don't append this to the query
        elseif (arg == '-f') 
            if (curr_idx + 1 < num_args)
                let curr_idx = curr_idx + 1
                let option = a:000[curr_idx]
                let split_filetypes = split(option, ',') 
                for filetype in split_filetypes
                    echom "Adding filetype " . filetype . " to desired filetypes list"
                    let filetypes[filetype] = 1
                endfor
            else
              echoe "No argument for -f option?"
            endif " next argument is valid
        elseif (arg == '-Nf')
            if (curr_idx + 1 < num_args)
                let curr_idx = curr_idx + 1
                let option = a:000[curr_idx]
                let split_filetypes = split(option, ',') 
                for filetype in split_filetypes
                    echom "Adding filetype " . filetype . " to ignored filetypes list"
                    let filetypes[filetype] = 0
                endfor
            else
              echoe "No argument for -Nf option?"
            endif " next argument is valid
        elseif (arg == '-d')
            if (curr_idx + 1 < num_args)
                let curr_idx = curr_idx + 1
                let option = a:000[curr_idx]
                let split_dirs = split(option, ',') 
                for dir in split_dirs
                    echom "Adding dir " . dir . " to desired directories list"
                    if (dir[len(dir) - 1] == '/')
                        let dir = dir[0:len(dir) - 1]
                    endif
                    let directories[dir] = 1
                endfor
            else
              echoe "No argument for -d option?"
            endif
        elseif (arg == '-Nd')
            if (curr_idx + 1 < num_args)
                let curr_idx = curr_idx + 1
                let option = a:000[curr_idx]
                let split_dirs = split(option, ',') 
                for dir in split_dirs
                    echom "Adding dir " . dir . " to ignored directories list"
                    if (dir[len(dir) - 1] == '/')
                        let dir = dir[0:len(dir) - 1]
                    endif
                    let directories[dir] = 0
                endfor
            else
              echoe "No argument for -Nd option?"
            endif " next argument is valid
        elseif (arg == '-p')
            if (curr_idx + 1 < num_args)
                let curr_idx = curr_idx + 1
                let preset = a:000[curr_idx]
                echom "Set preset " . preset
            else
              echoe "No argument for -p option?"
            endif " next argument is valid
        else
          " Not a flag, starting query concatenation
          let query_started = 1
        endif 
    endif " !query_started

    if (query_started)
      if (len(query) == 0)
        let query = arg 
      else
        let query = printf('%s %s', query, arg) 
      endif
    endif " query_started

    let curr_idx = curr_idx + 1
  endwhile
  
  " Default preset behavior, only populate filters if nothing is specified
  let default_filetypes = [
    \ 'py',
    \ 'cc',
    \ 'h',
    \ 'lcm',
    \ 'proto',
    \ 'djinni', 
    \ 'mm',
    \ 'm',
    \ 'swift',
    \ 'java',
    \ 'kt',
    \ 'cmake',
    \ ]
  let default_ignored_dirs = [
    \ 'build',
    \ 'third_party_modules',
    \ 'third_party',
    \ 'bazel-out',
    \ '*/node_modules',
    \ ]

   if (preset == '')
       " Only populate filetypes if empty, just for perf
      if (len(filetypes) == 0)
          for type in default_filetypes
            let filetypes[type] = 1
          endfor
      endif

      " Only ignore the dir if not already specified
      for dir in default_ignored_dirs 
        if (!has_key(directories, dir))
            let directories[dir] = 0
        endif
      endfor
  endif
  
  " Just a generic place to put non-specific patterns
  let generic_globing = ''

  " Generate file globing patterns
  let desired_types = ''
  let ignored_types = ''
  for key in keys(filetypes)
    if (filetypes[key]) 
      if (len(desired_types) == 0)
        let desired_types = key
      else
        let desired_types = desired_types . ',' . key
      endif
    else 
      if (len(desired_types) == 0)
        let ignored_types = key
      else
        let ignored_types = ignored_types . ',' . key
      endif
    endif
  endfor

  let desired_dirs = ''
  for key in keys(directories)
    if (directories[key]) 
        if (len(desired_dirs) == 0)
          let desired_dirs = key 
        else 
          let desired_dirs = desired_dirs . ' ' . key 
        endif
    else 
        let generic_globing = generic_globing . printf('-g "!%s/**" ', key) 
    endif
  endfor

  echom "Got desired filetypes list " . desired_types
  echom "Got ignored filetypes list " . ignored_types
  echom "Got desired dirs list " . desired_dirs
  echom "Got generic globing " . generic_globing
  echom "query arg is " . query

  if (len(desired_types) > 0)
    " Desired patterns should come first, to allow exclusionary patterns to take precedence
    " let generic_globing = printf('-g "{%s}/**.{%s}" ', desired_dirs, desired_types) . generic_globing 
    let generic_globing = printf('-g "*.{%s}" ', desired_types) . generic_globing 
  else
    let generic_globing = printf('-g "{%s}/**" ', desired_dirs) . generic_globing 
  endif

  if (len(ignored_types) > 0)
    let generic_globing = generic_globing . printf('-g "!*.{%s}" ', ignored_types)
  endif

  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case
              \ %s -- %s  %s || true
              \'

  let initial_command = printf(command_fmt, generic_globing, shellescape(query), desired_dirs)
  let reload_command = printf(command_fmt, generic_globing, '{q}', desired_dirs)

  echom "Got initial command " . initial_command
  echom "Got reload command " . reload_command
  let spec = {'options': ['--phony', '--query', query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), 0)
endfunction

command! -nargs=* -bang RG call SkyRipgrepFzf(<f-args>)
command! -nargs=* -bang RGN call SkyRipgrepFzf('--', <f-args>)

" ==================================================================================================
" Signify Configuration
" ==================================================================================================
let g:signify_vcs_list = ['git', 'svn', 'hg']
let g:signify_sign_change = '~'
let g:signify_sign_delete = '-'
let g:signify_update_on_focusgained = 1

" ==================================================================================================
" YCM Configuration
" ==================================================================================================
let g:ycm_confirm_extra_conf = 0 " Turn off confirmation prompt on first use every time vim opens

" ==================================================================================================
" NERD* Configuration
" ==================================================================================================
let g:NERDSpaceDelims=1

" ==================================================================================================
" CPP Functions
" ==================================================================================================
" Configuration for C-like languages.
function! SetupForCLang()
    " Use 2 spaces for indentation.
    setlocal shiftwidth=2
    setlocal tabstop=2
    setlocal softtabstop=2
    setlocal expandtab

    " Configure auto-indentation formatting.
    setlocal cindent
    setlocal cinoptions=h1,l1,g1,t0,i4,+4,(0,w1,W4
    setlocal indentexpr=GoogleCppIndent()
    let b:undo_indent = "setl sw< ts< sts< et< tw< wrap< cin< cino< inde<"

    " Uncomment these lines to map F5 to the CEF style checker. Change the path to match your system.
    " map! <F5> <Esc>:!python ~/code/chromium/src/cef/tools/check_style.py %:p 2> lint.out<CR>:cfile lint.out<CR>:silent !rm lint.out<CR>:redraw!<CR>:cc<CR>
    " map  <F5> <Esc>:!python ~/code/chromium/src/cef/tools/check_style.py %:p 2> lint.out<CR>:cfile lint.out<CR>:silent !rm lint.out<CR>:redraw!<CR>:cc<CR>
endfunction

" From https://github.com/vim-scripts/google.vim/blob/master/indent/google.vim
function! GoogleCppIndent()
    let l:cline_num = line('.')

    let l:orig_indent = cindent(l:cline_num)

    if l:orig_indent == 0 | return 0 | endif

    let l:pline_num = prevnonblank(l:cline_num - 1)
    let l:pline = getline(l:pline_num)
    if l:pline =~# '^\s*template' | return l:pline_indent | endif

    " TODO: I don't know to correct it:
    " namespace test {
    " void
    " ....<-- invalid cindent pos
    "
    " void test() {
    " }
    "
    " void
    " <-- cindent pos
    if l:orig_indent != &shiftwidth | return l:orig_indent | endif

    let l:in_comment = 0
    let l:pline_num = prevnonblank(l:cline_num - 1)
    while l:pline_num > -1
        let l:pline = getline(l:pline_num)
        let l:pline_indent = indent(l:pline_num)

        if l:in_comment == 0 && l:pline =~ '^.\{-}\(/\*.\{-}\)\@<!\*/'
            let l:in_comment = 1
        elseif l:in_comment == 1
            if l:pline =~ '/\*\(.\{-}\*/\)\@!'
                let l:in_comment = 0
            endif
        elseif l:pline_indent == 0
            if l:pline !~# '\(#define\)\|\(^\s*//\)\|\(^\s*{\)'
                if l:pline =~# '^\s*namespace.*'
                    return 0
                else
                    return l:orig_indent
                endif
            elseif l:pline =~# '\\$'
                return l:orig_indent
            endif
        else
            return l:orig_indent
        endif

        let l:pline_num = prevnonblank(l:pline_num - 1)
    endwhile

    return l:orig_indent
endfunction


" ==================================================================================================
" Visual appearance
" NOTE: needs to come at the end to override any previous options that sneakily made it in.
" TODO: Why isn't my python syntax highlighting working...?
" ==================================================================================================
let g:airline_powerline_fonts = 1

" Enable terminal gui colors for wider color selection options
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

" Color scheme
" autocmd vimenter * ++nested colorscheme gruvbox
" autocmd vimenter * ++nested colorscheme monokai
autocmd vimenter * ++nested colorscheme base16-gruvbox-dark-hard

" YCM highlighting behavior
" highlight YcmErrorLine ctermbg=DarkRed
" highlight YcmErrorSection ctermbg=White ctermfg=Black
highlight YcmErrorLine guibg=#260000
highlight YcmErrorSection guibg=#760000

" Ruler and margins
set ruler
set colorcolumn=101
" highlight ColorColumn ctermbg=0 guibg=lightgrey
" highlight OverLength ctermbg=darkred ctermfg=white guibg=#FFD9D9
highlight ColorColumn guibg=#000072
highlight OverLength guibg=#720000
