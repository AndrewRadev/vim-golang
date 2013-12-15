function! go#env#Root()
  if executable('go')
    let goroot = substitute(system('go env GOROOT'), '\n', '', 'g')
    if v:shell_error
      echo '''go env GOROOT'' failed'
    endif
  else
    let goroot = $GOROOT
  endif

  return goroot
endfunction

function! go#env#Arch()
  if exists('s:goarch')
    return s:goarch
  endif

  let s:goarch = $GOARCH

  if len(s:goarch) == 0
    if exists('g:golang_goarch')
      let s:goarch = g:golang_goarch
    else
      let s:goarch = '*'
    endif
  endif

  return s:goarch
endfunction

function! go#env#Os()
  if exists('s:goos')
    return s:goos
  endif

  let s:goos = $GOOS

  if len(s:goos) == 0
    if exists('g:golang_goos')
      let s:goos = g:golang_goos
    elseif has('win32') || has('win64')
      let s:goos = 'windows'
    elseif has('macunix')
      let s:goos = 'darwin'
    else
      let s:goos = '*'
    endif
  endif

  return s:goos
endfunction
