" TODO:
" - function invocations split across lines
" - general line splits (line ends in an operator)
"
function! go#indent#Main(lnum)
  let thislnum = a:lnum

  let thisline = go#indent#line#New(thislnum)
  let prevline = thisline.Prev()
  if empty(prevline)
    " top of file
    return 0
  endif

  " TODO (2014-04-06) This is very iffy, needs a better heuristic
  if thisline.MatchSyntax(1, 'string', 'comment') &&
        \ thisline.MatchSyntax(col('$'), 'string', 'comment')
    " we shouldn't touch its indentation
    return -1
  endif

  if empty(prevline.Parent())
    " no parent, the previous line is the one we care for
    let ind = prevline.Indent()
  else
    " we should use the parent indent as base
    " TODO (2013-12-28) what else do we need the "parent" for?
    let ind = prevline.Parent().Indent()
  endif

  if prevline.MatchAtEnd('[+*/-]')
    let ind += &sw
  endif

  if prevline.MatchAtEnd('[({]\s*')
    " previous line opened a block
    let ind += &sw
  endif
  if prevline.MatchAtEnd('^\s*\(case .*\|default\):')
    " previous line is part of a switch statement
    let ind += &sw
  endif
  " TODO: handle if the previous line is a label.
  if thisline.Match('^\s*[)}]')
    " this line closed a block
    let ind -= &sw
  endif

  " Colons are tricky.
  " We want to outdent if it's part of a switch ("case foo:" or "default:").
  " We ignore trying to deal with jump labels because (a) they're rare, and
  " (b) they're hard to disambiguate from a composite literal key.
  if thisline.MatchAtEnd('^\s*\(case .*\|default\):')
    let ind -= &sw
  endif

  return ind
endfunction
