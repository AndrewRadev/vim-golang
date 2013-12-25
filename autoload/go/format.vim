function! go#format#Run(options)
  let silent = get(a:options, 'silent', 0)
  let write  = get(a:options, 'write', 0)

  let view = winsaveview()

  let diff = system('gofmt -d '.expand('%'))
  if diff =~ '^\_s*$'
    " no changes, don't do anything
    return
  elseif v:shell_error && silent
    " ignore the error
    return
  elseif v:shell_error
    let error_lines = split(diff, "\n")
    let errors      = []

    let saved_errorformat = &l:errorformat
    let &errorformat = '%f:%l:%c%m'
    lexpr error_lines
    let &l:errorformat = saved_errorformat
    lopen
  else
    silent %!gofmt
  endif

  call winrestview(view)
endfunction
