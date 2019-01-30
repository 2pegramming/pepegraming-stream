module Web
  module Controllers
    module Feeds
      class Show
        include Web::Action

        def call(params)
        end
      end
    end
  end
end

# Web::Controllers::Feeds::Show.new # => object
# Web::Controllers::Feeds::Show.new.call({ ... }) # => call action
