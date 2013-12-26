if exists("b:did_ftplugin")
  finish
endif

set includeexpr=go#open#Find(v:fname)

command! -buffer A  exe 'edit '           . go#TestFile()
command! -buffer AE exe 'edit '           . go#TestFile()
command! -buffer AS exe 'split '          . go#TestFile()
command! -buffer AV exe 'vertical split ' . go#TestFile()
command! -buffer AT exe 'tabnew '         . go#TestFile()
command! -buffer AD exe 'read '           . go#TestFile()

command! -buffer -nargs=* -complete=custom,go#format#Complete
      \ Fmt call go#format#Run(<f-args>)

command! -buffer -nargs=? -complete=customlist,go#complete#Package Drop     call go#import#Switch(0, '', <f-args>)
command! -buffer -nargs=* -complete=customlist,go#complete#Package Import   call go#import#Switch(1, '', <f-args>)
command! -buffer -nargs=* -complete=customlist,go#complete#Package ImportAs call go#import#Switch(1, <f-args>)
map <buffer> <LocalLeader>f :Import fmt<CR>
map <buffer> <LocalLeader>F :Drop fmt<CR>

" Function text object
onoremap <buffer> af :<c-u>call go#textobj#Function('a')<cr>
xnoremap <buffer> af :<c-u>call go#textobj#Function('a')<cr>
onoremap <buffer> if :<c-u>call go#textobj#Function('i')<cr>
xnoremap <buffer> if :<c-u>call go#textobj#Function('i')<cr>

" Jumping to start of next/previous function
" Note: [] and ][ should already be working fine for Go
nnoremap <buffer> [[ :<c-u>call <SID>Section('b', 'n')<cr>
nnoremap <buffer> ]] :<c-u>call <SID>Section('', 'n')<cr>
xnoremap <buffer> [[ :<c-u>call <SID>Section('b', 'v')<cr>
xnoremap <buffer> ]] :<c-u>call <SID>Section('', 'v')<cr>

function! s:Section(flags, mode)
  if a:mode == 'v'
    normal! gv
  endif

  call search('^\s*func\>', 'W'.a:flags)
endfunction

command! -buffer -nargs=* Play call s:Play(<f-args>)
function! s:Play(...)
  if a:0 == 0
    " We should try to post to the playground, but do nothing for now
    return
  endif

  let url = a:1.'.go'
  let output = system('curl -s '.shellescape(url))
  if v:shell_error
    echoerr output
    return
  endif

  let saved_view = winsaveview()
  %delete _
  call setline(1, split(output, "\n"))
  call winrestview(saved_view)
endfunction

let b:did_ftplugin           = 1
let b:did_ftplugin_go_fmt    = 1
let b:did_ftplugin_go_import = 1
