if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

" C indentation is too far off useful, mainly due to Go's := operator.
" Let's just define our own.
setlocal nolisp
setlocal noautoindent
setlocal indentexpr=go#indent#Main(v:lnum)
setlocal indentkeys+=<:>,0=},0=)
