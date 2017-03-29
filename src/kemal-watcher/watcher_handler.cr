require "kemal"

module Kemal
  class WatcherHandler < Kemal::Handler
    def call(context)
      context.response.print render "src/kemal-watcher/client_websocket.ecr"
      call_next context
    end
  end
end
