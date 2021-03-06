function! go#Dirs()
  let dirs   = []
  let goroot = go#env#Root()

  if len(goroot) != 0 && isdirectory(goroot)
    let dirs += [ goroot ]
  endif

  let workspaces = split($GOPATH, ':')
  if workspaces != []
    let dirs += workspaces
  endif

  return dirs
endfunction

function! go#FindImports()
  let packages = {}

  try
    let saved_view = winsaveview()

    normal! gg
    if search('import\s\+\zs(', 'W') <= 0
      return {}
    endif

    let start_lineno = nextnonblank(line('.') + 1)
    normal! %
    let end_lineno = prevnonblank(line('.') + 1)

    let named_package_pattern   = '^\s*\(\k\+\)\s\+"\(\%(\k\|\/\)\+\)"$'
    let unnamed_package_pattern = '^\s*"\(\%(\k\|\/\)\+\)"$'

    for line in getbufline('%', start_lineno, end_lineno)
      if line =~ named_package_pattern
        let package_name = substitute(line, named_package_pattern, '\1', '')
        let package_path = substitute(line, named_package_pattern, '\2', '')
      elseif line =~ unnamed_package_pattern
        let package_path = substitute(line, unnamed_package_pattern, '\1', '')
        let package_name = split(package_path, '/')[-1]
      else
        continue
      endif

      let packages[package_name] = package_path
    endfor
  finally
    call winrestview(saved_view)
  endtry

  return packages
endfunction

function! go#TestFile()
  let basename = expand('%:r')

  if basename =~# '_test$'
    return substitute(basename, '_test$', '', '').'.go'
  else
    return basename.'_test.go'
  endif
endfunction

function! go#FindFile(fname)
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
