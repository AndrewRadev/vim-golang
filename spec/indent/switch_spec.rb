require 'spec_helper'

describe "Indenting" do
  specify "switch statements" do
    assert_correct_indenting <<-EOF
      switch a {
      case 1:
          "foo"
      case 2:
          "bar"
      default:
          "baz"
      }
    EOF
  end
end
