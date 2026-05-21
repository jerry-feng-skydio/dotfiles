" ~/.dotfiles/skyrg/actions/example.vim — Example async action (demo)

if !exists('g:skyrg_context_actions')
  let g:skyrg_context_actions = []
endif

call add(g:skyrg_context_actions, {
  \ 'name':      'Example: fake build',
  \ 'key':       'e',
  \ 'group':     'example',
  \ 'priority':  200,
  \ 'predicate': {ctx -> !empty(ctx.word)},
  \ 'job':       {ctx -> '~/.dotfiles/scripts/skyrg_example_action.sh ' . shellescape(ctx.word)},
  \ 'job_opts':  {
  \   'title': 'Fake build',
  \   'output_format': 'matches',
  \   'on_failure': [
  \     {
  \       'name': 'Show parsed errors',
  \       'key':  's',
  \       'execute': {ctx -> execute('echom "[SkyRG] Parsed ' . 'errors: " . len(ctx.task_output)')},
  \     },
  \     {
  \       'name': 'Jump to first error',
  \       'key':  'j',
  \       'execute': {ctx -> s:jump_to_first(ctx)},
  \     },
  \   ],
  \ },
  \ })

call add(g:skyrg_context_actions, {
  \ 'name':      'Example: pipe selection',
  \ 'key':       'p',
  \ 'group':     'example',
  \ 'priority':  201,
  \ 'predicate': {ctx -> !empty(ctx.visual)},
  \ 'job':       '~/.dotfiles/scripts/skyrg_example_stdin.sh',
  \ 'job_opts':  {
  \   'title': 'Pipe stdin',
  \   'stdin': {ctx -> ctx.visual},
  \   'output_format': 'lines',
  \   'on_success': [
  \     {
  \       'name': 'Show output in split',
  \       'key':  's',
  \       'execute': {ctx -> s:show_in_scratch(ctx.task_output)},
  \     },
  \   ],
  \ },
  \ })

call add(g:skyrg_context_actions, {
  \ 'name':      'Example: interactive deploy',
  \ 'key':       'i',
  \ 'group':     'example',
  \ 'priority':  202,
  \ 'predicate': {ctx -> 1},
  \ 'job':       '~/.dotfiles/scripts/skyrg_example_interactive.sh',
  \ 'job_opts':  {
  \   'title': 'Deploy',
  \   'interactive': 1,
  \   'term_rows': 10,
  \ },
  \ })

function! s:show_in_scratch(lines) abort
  new
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
  file [SkyRG\ Output]
  call setline(1, a:lines)
  setlocal nomodifiable
endfunction

function! s:jump_to_first(ctx) abort
  if empty(a:ctx.task_output)
    echom '[SkyRG] No errors to jump to'
    return
  endif
  let l:m = a:ctx.task_output[0]
  echom printf('[SkyRG] Would jump to %s:%d:%d — %s', l:m.file, l:m.lnum, l:m.col, l:m.text)
endfunction
