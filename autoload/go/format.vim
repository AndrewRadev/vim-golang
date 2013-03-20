function! go#format#Run()
  let view = winsaveview()
  silent %!gofmt
  if v:shell_error
    let errors = []
    for line in getline(1, line('$'))
      let tokens = matchlist(line, '^\(.\{-}\):\(\d\+\):\(\d\+\)\s*\(.*\)')
      if !empty(tokens)
        call add(errors, {
              \ "filename": @%,
              \ "lnum":     tokens[2],
              \ "col":      tokens[3],
              \ "text":     tokens[4]
              \ })
      endif
    endfor
    if empty(errors)
      % | " Couldn't detect gofmt error format, output errors
    endif
    undo
    if !empty(errors)
      call setloclist(0, errors, 'r')
    endif
    echohl Error | echomsg "Gofmt returned error" | echohl None
  endif
  call winrestview(view)
endfunction