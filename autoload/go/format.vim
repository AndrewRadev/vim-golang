function! go#format#Run(...)
  let options = a:000

  " Do nothing in case of errors
  let silent = (index(options, 'silent') >= 0)

  " Always write the file afterwards
  let write = (index(options, 'write') >= 0)

  " Provide the -s flag to gofmt
  let simplify = (index(options, 'simplify') >= 0)

  try
    let view = winsaveview()

    let gofmt = 'gofmt'
    if simplify
      let gofmt .= ' -s'
    endif

    " Filter the buffer contents through gofmt
    " Note: should line endings vary depending on OS?
    let diff = system(gofmt.' -d', join(getbufline('%', 0, '$'), "\n")."\n")

    if diff =~ '^\_s*$'
      " no changes, don't do anything
      return
    elseif v:shell_error && silent
      " ignore the error
      return
    elseif v:shell_error
      " `gofmt -d` got its output from stdin, we should adjust a bit
      let diff = substitute(diff, '<standard input>', expand('%'), 'g')

      let error_lines = split(diff, "\n")
      let errors      = []

      " Read errors in the location list
      let saved_errorformat = &l:errorformat
      let &errorformat = '%f:%l:%c%m'
      lexpr error_lines
      let &l:errorformat = saved_errorformat
      lopen
    else
      " No errors, there were changes, trigger a full gofmt
      exe 'silent %!'.gofmt
    endif
  finally
    if write
      update
    endif

    call winrestview(view)
  endtry
endfunction

function! go#format#Complete(...)
  return join(['silent', 'write', 'simplify'], "\n")
endfunction
