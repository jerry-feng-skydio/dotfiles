" Dec 30, 2021 -- version 1.0
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

