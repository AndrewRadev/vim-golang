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
- `:Fmt` can be given several arguments that change its behaviour

For the official runtime files, straight from the Golang project, go to
[golang.org/misc/vim/](http://golang.org/misc/vim/).

## Usage

This plugin provides filetype detection, syntax highlighting and indentation
for the Go programming language. It also includes some useful tools for working
with Go code.

For the most basic usage, just install the plugin and edit Go code. You should
get the basic benefits automatically.

If you want to use the other tools, please take a look at the documentation in
`doc/golang.txt`, or within Vim itself with `:help golang`.

## Installation

There are several ways to install the plugin. The recommended one is by using
Tim Pope's [pathogen](http://www.vim.org/scripts/script.php?script_id=2332). In
that case, you can clone the plugin's git repository like so:

    git clone git://github.com/AndrewRadev/vim-golang.git ~/.vim/bundle/golang

If your vim configuration is under git version control, you could also set up
the repository as a submodule, which would allow you to update more easily. The
command is (provided you're in `~/.vim`):

    git submodule add git://github.com/AndrewRadev/vim-golang.git bundle/golang

Another way is to simply copy all the essential directories inside the ~/.vim
directory: autoload, doc, ftdetect, ftplugin, indent, plugin, syntax.
