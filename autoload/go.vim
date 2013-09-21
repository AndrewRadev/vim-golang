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
