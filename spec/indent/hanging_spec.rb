require 'spec_helper'

describe "Indent" do
  specify "hanging operators" do
    assert_correct_indenting <<-EOF
      one := 1 +
          2 +
          3
      two := one *
          3
      three := two + 1
    EOF
  end
end
