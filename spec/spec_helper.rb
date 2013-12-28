require 'vimrunner'
require 'vimrunner/rspec'

Vimrunner::RSpec.configure do |config|
  config.reuse_server = true

  config.start_vim do
    vim = Vimrunner.start_gvim
    vim.prepend_runtimepath(File.expand_path('../..', __FILE__))
    vim.set 'noexpandtab'
    vim.set 'shiftwidth', 4
    vim.set 'tabstop', 4
    vim
  end

  def assert_correct_indenting(string)
    whitespace = string.scan(/^\s*/).first
    string = string.
      split("\n").
      map { |line| line.gsub /^#{whitespace}/, '' }.
      map { |line| line.gsub /^ {4}|(?<=\s) {4}/, "\t" }.
      join("\n").strip

    File.open 'test.go', 'w' do |f|
      f.write string
    end

    vim.edit 'test.go'
    vim.normal 'gg=G'
    vim.write

    IO.read('test.go').strip.should eq string
  end
end
