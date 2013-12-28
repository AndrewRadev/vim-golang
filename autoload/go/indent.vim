" TODO:
" - function invocations split across lines
" - general line splits (line ends in an operator)
"
function! go#indent#Main(lnum)
  let thislnum = a:lnum
  let prevlnum = prevnonblank(a:lnum-1)
  if prevlnum == 0
    " top of file
    return 0
  endif

  let prevline = go#indent#NewLine(prevlnum)
  let thisline = go#indent#NewLine(thislnum)

  let eol_pattern = '\%($\|//.*$\)'
  let ind         = prevline.Indent()

  " TODO (2013-12-24) Handle MSL -- hanging ) at EOL. Poke around in matchparen.vim
  "
  " if thisline.MatchSyntax(1, 'string', 'comment')
  "   " we shouldn't touch its indentation
  "   return -1
  " endif

  if prevline.Match('[({]\s*'.eol_pattern)
    " previous line opened a block
    let ind += &sw
  endif
  if prevline.Match('^\s*\(case .*\|default\):'.eol_pattern)
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
  if thisline.Match('^\s*\(case .*\|default\):'.eol_pattern)
    let ind -= &sw
  endif

  return ind
endfunction

function! go#indent#NewLine(lnum)
  let line = {
        \ 'num': a:lnum,
        \ 'body': '',
        \ }

  function! line.Body() dict
    if self.body != '' | return self.body | endif

    let self.body = getline(self.num)
    return self.body
  endfunction

  function! line.Indent() dict
    return indent(self.num)
  endfunction

  function line.Match(regex) dict
    let line   = self.Body()
    let offset = match(line, '\C'.a:regex)
    let col    = offset + 1

    while offset > -1 && self.MatchSyntax(col, 'string', 'comment')
      let offset = match(line, '\C'.a:regex, offset + 1)
      let col = offset + 1
    endwhile

    if offset > -1
      return col
    else
      return 0
    endif
  endfunction

  function! line.MatchSyntax(col, ...)
    let syntax_kinds     = a:000
    let syntax_group_set = {}

    for kind in syntax_kinds
      if kind ==# 'string'
        let syntax_group_set['goString'] = 1
        let syntax_group_set['goRawString'] = 1
      elseif kind ==# 'comment'
        let syntax_group_set['goComment'] = 1
      endif
    endfor

    let syntax_groups = keys(syntax_group_set)
    let syntax_pattern = '\<'.join(syntax_groups, '\|').'\>'

    return synIDattr(synID(self.num, a:col, 1), 'name') =~ syntax_pattern
  endfunction

  return line
endfunction
