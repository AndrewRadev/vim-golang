This project is my own fork of Go's Vim runtime files. I intend to add some
additional features to it that won't make their way upstream, but which you
may find useful.

Some notable changes:

- `:Godoc` is smarter, and can now look for a particular symbol (function call)
  as well as packages.
- Minimal syntax highlighting for the `godoc` buffer.
- Function text objects
- The `gf` family of mappings work for packages
- The `:A` command opens the related test file

For the official runtime files, straight from the Golang project, go to
[golang.org/misc/vim/](http://golang.org/misc/vim/).

## Usage

This plugin provides filetype detection, syntax highlighting and indentation
for the Go programming language. It also includes some useful tools for
working with Go code. For the most basic usage, just install the plugin and
edit Go code. You should get the basic benefits automatically. If you want to
use the other tools, read ahead.

This is a list of the provided commands:
- `:A`, `:AE`, `:AS`, `:AV`, `:AT`, `:AD`

  These commands were picked to mimic Michael Sharpe's a.vim. Briefly, they
  edit the "alternate" file, in either the same window (`:A` and `:AE`), a
  new split window (`:AS`), a new vertically split window (`:AV`), a new tab
  (`:AT`), or read it into the current buffer (`:AD`).

  In go's case, the "alternate" file would always be the test file.

- `:Fmt`

  Filter the current Go buffer through gofmt. It tries to preserve cursor
  position and avoids replacing the buffer with stderr output.

- `:Import {path}`

  Import ensures that the provided package {path} is imported in the current
  Go buffer, using proper style and ordering. If {path} is already being
  imported, an error will be displayed and the buffer will be untouched.

- `:ImportAs {localname} {path}`

  Same as Import, but uses a custom local name for the package.

- `:Drop {path}`

  Remove the import line for the provided package {path}, if present in the
  current Go buffer.  If {path} is not being imported, an error will be
  displayed and the buffer will be untouched.

- `:Godoc [package-name] [function-name]`

  Display documentation from godoc for the given `package-name`. If
  `function-name` is also provided, shows documentation for this particular
  function in this package.

  If called without any arguments, tries to find a package or a
  package-prefixed function, (for example, `fmt.Printf`), and makes a query
  for that.

  Tab-completes with all known package names.

Mappings:

- `\f` -  Runs :Import fmt
- `\F` -  Runs :Drop fmt
- `if`, `af` - "Function" text objects

The backslash is the default `maplocalleader`, so it is possible that your vim
is set to use a different character (`:help maplocalleader`).

The built-in `gf` mapping works correctly for imports, along with all related
ones, like `<c-w>f`.

## Settings

These are the variables that control the behaviour of the plugin. You can
write:

``` vim
let OPTION_NAME = 0
```

in your `~/.vimrc` file to disable particular options. You can also write:

``` vim
let OPTION_NAME = 1
```

to enable particular options. At present, all options default to on.

- `go_highlight_array_whitespace_error`

    Highlights white space after "[]".

- `go_highlight_chan_whitespace_error`

    Highlights white space around the communications operator that don't follow
    the standard style.

- `go_highlight_extra_types`

    Highlights commonly used library types (io.Reader, etc.).

- `go_highlight_space_tab_error`

    Highlights instances of tabs following spaces.

- `go_highlight_trailing_whitespace_error`

    Highlights trailing white space.
