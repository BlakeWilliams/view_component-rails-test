module Tests
  class Index < ViewComponent::Base
    def initialize
    end

    def call
      render "tests/omg" do
        "rad"
      end
    end
  end
end
