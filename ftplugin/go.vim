if exists("b:did_ftplugin")
  finish
endif

command! -buffer Fmt call go#format#Run()
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

let b:did_ftplugin = 1
