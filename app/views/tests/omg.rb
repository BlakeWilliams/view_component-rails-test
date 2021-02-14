module Tests
  class Omg < ViewComponent::Base
    def initialize
    end

    def call
      content_tag :h1 do
        content
      end
    end
  end
end
