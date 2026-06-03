" ~/.dotfiles/skyrg/global.vim — Shared SkyRG settings (all projects)

" Context popup trigger
let g:skyrg_context_key = '<Leader>a'

" Logging
let g:skyrg_log_level = 'DEBUG'

" Task viewer
nnoremap <silent> <Leader>t :SkyRGTasks<CR>

" Followup actions (most recent awaiting task)
nnoremap <silent> <Leader>f :SkyRGFollowup<CR>

" Statusline task indicator
set statusline+=%{skyrg#backend#tasks#statusline()}

" Ensure action list exists for append pattern
if !exists('g:skyrg_context_actions')
  let g:skyrg_context_actions = []
endif

" Auto-detect devices on USB plug/unplug
call skyrg#backend#device#watch_usb()
