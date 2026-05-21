" ~/.dotfiles/skyrg/global.vim — Shared SkyRG settings (all projects)

" Context popup trigger
let g:skyrg_context_key = '<Leader>a'

" Logging
" let g:skyrg_log_level = 'DEBUG'

" Statusline task indicator
set statusline+=%{skyrg#backend#tasks#statusline()}

" Ensure action list exists for append pattern
if !exists('g:skyrg_context_actions')
  let g:skyrg_context_actions = []
endif
