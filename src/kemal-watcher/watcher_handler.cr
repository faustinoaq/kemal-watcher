require "kemal"

module Kemal
  # The right way to handle context is Kemal::Handler
  # but I can not check response content type easily
  # In future release the code below could change
  # class WatcherHandler < Kemal::Handler
  #   def call(context)
  #     call_next context
  #   end
  # end
end
