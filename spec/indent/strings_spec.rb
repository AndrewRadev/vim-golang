require 'spec_helper'

describe "Indenting" do
  specify "multi-line strings" do
    assert_correct_indenting <<-EOF
      if 1 == 1 {
          Process(`
              = Title =
        One
            - Two
            - Three
        `)
          _ := otherLine()
      }
    EOF
  end
end
