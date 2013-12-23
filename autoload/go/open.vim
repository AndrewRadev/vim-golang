" TODO (2013-12-15) Consider organizing functions in a better way
function! go#open#Find(fname)
  let dirs = []
  for dir in go#Dirs()
    call add(dirs, dir.'/src/')
    call add(dirs, dir.'/src/pkg/')
  endfor

  let file_glob = globpath(join(dirs, ','), a:fname)
  let files = split(file_glob, "\n")

  if empty(files)
    return ''
  else
    return files[0]
  endif
endfunction
