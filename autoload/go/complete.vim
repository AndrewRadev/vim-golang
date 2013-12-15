" This file provides a utility function that performs auto-completion of
" package names, for use by other commands.

function! go#complete#Package(ArgLead, CmdLine, CursorPos)
  let dirs = go#Dirs()

  if len(dirs) == 0
    " should not happen
    return []
  endif

  let ret = {}
  for dir in dirs
    let roots = split(expand(dir . '/pkg/' . go#env#Os() . '_' . go#env#Arch()), "\n")

    for root in roots
      for i in split(globpath(root, a:ArgLead.'*'), "\n")
        if isdirectory(i)
          let i .= '/'
        elseif i !~ '\.a$'
          continue
        endif
        let i = substitute(substitute(i[len(root)+1:], '[\\]', '/', 'g'), '\.a$', '', 'g')
        let ret[i] = i
      endfor
    endfor
  endfor
  return sort(keys(ret))
endfunction
