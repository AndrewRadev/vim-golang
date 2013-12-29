let s:eol_pattern = '\%($\|//.*$\)'

function! go#indent#line#New(lnum)
  if a:lnum <= 0
    return {}
  endif

  return {
        \ 'num': a:lnum,
        \
        \ 'Body':        function('go#indent#line#Body'),
        \ 'Indent':      function('go#indent#line#Indent'),
        \ 'Match':       function('go#indent#line#Match'),
        \ 'MatchAtEnd':  function('go#indent#line#MatchAtEnd'),
        \ 'MatchSyntax': function('go#indent#line#MatchSyntax'),
        \ 'Prev':        function('go#indent#line#Prev'),
        \ 'Parent':      function('go#indent#line#Parent'),
        \ }
endfunction

function! go#indent#line#Body() dict
  if has_key(self, 'body') | return self.body | endif

  let self.body = getline(self.num)
  return self.body
endfunction

function! go#indent#line#Indent() dict
  return indent(self.num)
endfunction

function go#indent#line#Match(regex) dict
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

function go#indent#line#MatchAtEnd(regex) dict
  return self.Match(a:regex.s:eol_pattern)
endfunction

function! go#indent#line#MatchSyntax(col, ...) dict
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

function! go#indent#line#Prev() dict
  if has_key(self, 'prev') | return self.prev | endif

  let self.prev = go#indent#line#New(prevnonblank(self.num - 1))
  return self.prev
endfunction

function! go#indent#line#Parent() dict
  if has_key(self, 'parent') | return self.parent | endif

  let self.parent = {}

  " TODO (2013-12-29) Operator pattern needs to be expanded (and shared?)
  if !empty(self.Prev())
    let operator_col = self.Prev().MatchAtEnd('[+*/-]')
    if operator_col
      while operator_col && !empty(self.Prev())
        let self.parent = self.Prev()
        let operator_col = self.parent.Prev().MatchAtEnd('[+*/-]')
      endwhile
      return self.parent
    endif
  endif

  " TODO (2013-12-28) Should look for many different parens
  " TODO (2013-12-28) Should look for rightmost paren
  let hanging_paren_col = self.MatchAtEnd('^[^(]*)')
  if hanging_paren_col
    let [lnum, _] = s:MatchingParen(self.num, hanging_paren_col)
    if lnum > -1
      let self.parent = go#indent#line#New(lnum)
      return self.parent
    endif
  endif

  return self.parent
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
