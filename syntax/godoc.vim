if exists("b:current_syntax")
  finish
endif

syn include @goTop syntax/go.vim

syn case match
syn match godocTitle "^\([A-Z- ]\+\)$"

syn region goFunctionLine    start=+^\zefunc+     end=+$+   contains=@goTop oneline
syn region goTypeDefinition  start=+^\zetype.*{+  end=+^}$+ contains=@goTop keepend
syn region goConstDefinition start=+^\zeconst.*(+ end=+^)$+ contains=@goTop keepend
syn region goVarDefinition   start=+^\zevar.*(+   end=+^)$+ contains=@goTop keepend

hi def link godocTitle Statement

let b:current_syntax = "godoc"
