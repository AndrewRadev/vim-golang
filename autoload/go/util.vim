function! go#util#Trim(s)
  let s = a:s
  let s = substitute(s, '^\_s\+', '', '')
  let s = substitute(s, '\_s\+$', '', '')

  return s
endfunction
