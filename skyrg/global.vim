" ~/.dotfiles/skyrg/global.vim — Shared SkyRG settings (all projects)

" Context popup trigger
let g:skyrg_context_key = '<Leader>a'

" Context popup pages — index maps to keyboard key (1234567890)
let g:skyrg_pages = {
  \ 1: {'name': 'Search'},
  \ 2: {'name': 'Workflows'},
  \ 3: {'name': 'Device'},
  \ 0: {'name': 'SkyRG'},
  \ 9: {'name': 'Buffer', 'auto': 1,
  \     'predicate': {-> skyrg#ui#live_split#is_live_split(bufnr('%'))}},
  \ }

" Map action groups to page indices
let g:skyrg_group_pages = {
  \ 'search': 1,
  \ 'open': 1,
  \ 'revup': 1,
  \ 'workflows': 2,
  \ 'device': 3,
  \ 'debug': 0,
  \ 'live_split': 9,
  \ }

" Logging
let g:skyrg_log_level = 'DEBUG'

" Task viewer
nnoremap <silent> <Leader>t :SkyRGTasks<CR>

" Followup actions (most recent awaiting task)
nnoremap <silent> <Leader>f :SkyRGFollowup<CR>

" Ensure action list exists for append pattern
if !exists('g:skyrg_context_actions')
  let g:skyrg_context_actions = []
endif

" Auto-detect devices on USB plug/unplug
call skyrg#backend#device#watch_usb()

" Workflows directory (default: .windsurf/workflows/ in project root)
" Set to a local-only path to avoid committing workflows to company repos:
"   let g:skyrg_workflows_dir = expand('~/.windsurf/workflows')
let g:skyrg_workflows_dir = expand('~/.windsurf/workflows')

