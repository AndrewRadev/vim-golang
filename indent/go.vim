" TODO:
" - function invocations split across lines
" - general line splits (line ends in an operator)
"
" - Vimrunner tests
"

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

" C indentation is too far off useful, mainly due to Go's := operator.
" Let's just define our own.
setlocal nolisp
setlocal noautoindent
setlocal indentexpr=GoIndent(v:lnum)
setlocal indentkeys+=<:>,0=},0=)

if exists("*GoIndent")
  finish
endif

function! GoIndent(lnum)
  let thislnum = a:lnum
  let prevlnum = prevnonblank(a:lnum-1)
  if prevlnum == 0
    " top of file
    return 0
  endif

  let previ       = indent(prevlnum)
  let eol_pattern = '\%($\|//.*$\)'
  let ind         = previ

  " TODO (2013-12-24) Handle MSL -- hanging ) at EOL. Poke around in matchparen.vim
  "
  " if s:IsInStringOrComment(thislnum, 1)
  "   " we shouldn't touch its indentation
  "   return -1
  " endif

  if s:Match(prevlnum, '[({]\s*'.eol_pattern)
    " previous line opened a block
    let ind += &sw
  endif
  if s:Match(prevlnum, '^\s*\(case .*\|default\):'.eol_pattern)
    " previous line is part of a switch statement
    let ind += &sw
  endif
  " TODO: handle if the previous line is a label.

  if s:Match(thislnum, '^\s*[)}]')
    " this line closed a block
    let ind -= &sw
  endif

  " Colons are tricky.
  " We want to outdent if it's part of a switch ("case foo:" or "default:").
  " We ignore trying to deal with jump labels because (a) they're rare, and
  " (b) they're hard to disambiguate from a composite literal key.
  if s:Match(thislnum, '^\s*\(case .*\|default\):$'.eol_pattern)
    let ind -= &sw
  endif

  return ind
endfunction

function s:Match(lnum, regex)
  let line   = getline(a:lnum)
  let offset = match(line, '\C'.a:regex)
  let col    = offset + 1

  while offset > -1 && s:IsInStringOrComment(a:lnum, col)
    let offset = match(line, '\C'.a:regex, offset + 1)
    let col = offset + 1
  endwhile

  if offset > -1
    return col
  else
    return 0
  endif
endfunction

" Check if the character at lnum:col is inside a string or comment
" TODO (2013-12-24) An object wrapping the line, with query methods?
function s:IsInStringOrComment(lnum, col)
  let pattern = '\<goString\|goRawString\|goComment\>'

  return synIDattr(synID(a:lnum, a:col, 1), 'name') =~ pattern
endfunction
