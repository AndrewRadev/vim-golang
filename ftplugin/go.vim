" Commands defined by this ftplugin:
"
"   :Fmt
"
"       Filter the current Go buffer through gofmt.
"       It tries to preserve cursor position and avoids
"       replacing the buffer with stderr output.
"
"   :Import {path}
"
"       Import ensures that the provided package {path} is imported
"       in the current Go buffer, using proper style and ordering.
"       If {path} is already being imported, an error will be
"       displayed and the buffer will be untouched.
"
"   :ImportAs {localname} {path}
"
"       Same as Import, but uses a custom local name for the package.
"
"   :Drop {path}
"
"       Remove the import line for the provided package {path}, if
"       present in the current Go buffer.  If {path} is not being
"       imported, an error will be displayed and the buffer will be
"       untouched.
"
" In addition to these commands, there are also two shortcuts mapped:
"
"   \f  -  Runs :Import fmt
"   \F  -  Runs :Drop fmt
"
" The backslash is the default maplocalleader, so it is possible that
" your vim is set to use a different character (:help maplocalleader).
"
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
