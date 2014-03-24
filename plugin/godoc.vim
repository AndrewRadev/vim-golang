if exists("g:loaded_godoc")
  finish
endif
let g:loaded_godoc = 1

let s:buf_nr = -1

command! -nargs=* -complete=customlist,go#complete#Package Godoc :call s:Godoc(<f-args>)
nnoremap <silent> <Plug>(godoc-keyword) :<c-u>call <SID>Godoc()<cr>

function! s:Godoc(...)
  let godoc = 'godoc -goroot='.go#env#Root()

  if a:0 > 0
    " we have a query
    let query = a:1
    let command = godoc.' '.query

    if query == ''
      return
    end
  else
    " build the query from what's under the cursor
    let packages = go#FindImports()
    let query    = expand('<cword>')

    if query == ''
      return
    end

    if has_key(packages, query)
      " then the query is a package, make it directly
      let command = godoc.' '.query
    else
      " the query is something else, look for a package around it
      let line            = getline('.')
      let line_prefix     = strpart(line, 0, stridx(line, query))
      let package_pattern = '^.\{-}\zs\k\+\ze\.$'

      if line_prefix =~ package_pattern
        " maybe it ends with a package?
        let parent_package = matchstr(line_prefix, package_pattern)
        if has_key(packages, parent_package)
          let parent_package = packages[parent_package]
        else
          " not really a package, ignore
          let parent_package = ''
        endif
      else
        let parent_package = ''
      endif

      if parent_package != ''
        let command = godoc.' '.parent_package.' '.query
      else
        let command = godoc.' -q '.query
      endif
    endif
  endif

  let output = system(command)
  if v:shell_error
    echo "Error executing '".command."'"
  endif

  call s:SetupGodocBuffer(go#util#Trim(output))
endfunction

function! s:SetupGodocBuffer(content)
  if !bufexists(s:buf_nr)
    belowright new
    keepalt file `="[Godoc]"`
    let s:buf_nr = bufnr('%')
  elseif bufwinnr(s:buf_nr) == -1
    belowright new
    execute s:buf_nr . 'buffer'
  elseif bufwinnr(s:buf_nr) != bufwinnr('%')
    execute bufwinnr(s:buf_nr) . 'wincmd w'
  endif

  setlocal filetype=godoc
  setlocal bufhidden=delete
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal nobuflisted

  setlocal modifiable
  %delete _
  call append(0, split(a:content, "\n"))
  $delete _
  setlocal nomodifiable

  normal! gg

  au BufHidden <buffer> call let <SID>buf_nr = -1
endfunction
