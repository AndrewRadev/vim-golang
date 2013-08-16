function! go#textobj#Function(mode)
  if search('^\s*func .*{$', 'Wce', line('.')) <= 0
        \ && search('^\s*func .*{$', 'bWce') <= 0
    return
  endif

  if a:mode == 'a'
    normal! Va{V
  elseif a:mode == 'i'
    normal! Vi{V
  else
    echoerr "Text object mode unknown: '".a:mode."'"
  endif
endfunction
