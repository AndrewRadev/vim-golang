require 'spec_helper'

describe "Indenting" do
  specify "block openings, curly brackets" do
    assert_correct_indenting <<-EOF
      func Test(s string) {
          return
      }
    EOF

    assert_correct_indenting <<-EOF
      list := []string{
          "one",
          "two",
      }
    EOF

    assert_correct_indenting <<-EOF
      person := Person{
          name: "John",
          age: 42,
      }
    EOF
  end

  specify "block openings, round brackets" do
    assert_correct_indenting <<-EOF
      func Test(
          s string,
          a int,
      )
    EOF
  end
end
