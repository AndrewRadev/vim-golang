let s:eol_pattern = '\%($\|//.*$\)'

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

  if empty(prevline.Parent())
    " no parent, the previous line is the one we care for
    let ind = prevline.Indent()
  else
    " we should use the parent indent as base
    " TODO (2013-12-28) what else do we need the "parent" for?
    let ind = prevline.Parent().Indent()
  endif

  " TODO (2013-12-24) Handle MSL -- hanging ) at EOL. Poke around in matchparen.vim
  "
  if thisline.MatchSyntax(1, 'string', 'comment')
    " we shouldn't touch its indentation
    return -1
  endif

  if prevline.Match('[({]\s*'.s:eol_pattern)
    " previous line opened a block
    let ind += &sw
  endif
  if prevline.Match('^\s*\(case .*\|default\):'.s:eol_pattern)
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
  if thisline.Match('^\s*\(case .*\|default\):'.s:eol_pattern)
    let ind -= &sw
  endif

  return ind
endfunction

function! go#indent#NewLine(lnum)
  let line = { 'num': a:lnum }

  function! line.Body() dict
    if has_key(self, 'body') | return self.body | endif

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

  function! line.Parent()
    if has_key(self, 'parent') | return self.parent | endif

    let self.parent = {}

    " TODO (2013-12-28) Should look for many different parens
    " TODO (2013-12-28) Should look for rightmost paren
    let hanging_paren_col = self.Match('^[^(]*)'.s:eol_pattern)
    if hanging_paren_col
      let [lnum, _] = s:MatchingParen(self.num, hanging_paren_col)
      if lnum > -1
        let self.parent = go#indent#NewLine(lnum)
      endif
    endif

    return self.parent
  endfunction

  return line
endfunction

" TODO (2013-12-28) Reimplement match.vim stuff?
function! s:MatchingParen(lnum, col)
  try
    let saved_view = winsaveview()

    let cursor = getpos('.')
    let cursor[1] = a:lnum
    let cursor[2] = a:col
    call setpos('.', cursor)
    normal %

    let new_lnum = line('.')
    let new_col = col('.')

    if new_lnum == a:lnum && new_col == a:col
      " no change, return failure
      return [-1, -1]
    endif

    return [line('.'), col('.')]
  finally
    call winrestview(saved_view)
  endtry
endfunction
