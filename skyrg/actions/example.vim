" ~/.dotfiles/skyrg/actions/example.vim — Example async action (demo)

if !exists('g:skyrg_context_actions')
  let g:skyrg_context_actions = []
endif

call add(g:skyrg_context_actions, {
  \ 'name':      'Example: echo word',
  \ 'key':       'e',
  \ 'group':     'example',
  \ 'priority':  200,
  \ 'predicate': {ctx -> !empty(ctx.word)},
  \ 'job':       {ctx -> '~/.dotfiles/scripts/skyrg_example_action.sh ' . shellescape(ctx.word)},
  \ 'job_opts':  {'title': 'Echo example'},
  \ })
