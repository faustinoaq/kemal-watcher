require "./kemal-watcher/*"
require "secure_random"
require "watcher"

module Kemal

  SOCKETS = [] of HTTP::WebSocket

  WEBSOCKETPATH = SecureRandom.hex(4)

  FILES = [] of String

  # Handle change when event.on_change and
  # send reload message to all clients
  private def self.handle_change
    SOCKETS.each do |socket|
      socket.send "reload"
    end
  end

  # Watch files in a concurrent way
  def self.watch(files)
    spawn do
      Watcher.watch files do |event|
        event.on_change do
          handle_change
        end
      end
    end
    add_handler WatcherHandler.new
  end

  # Start WebSocket server
  ws "/" + WEBSOCKETPATH do |socket|
    SOCKETS << socket
    socket.on_close do
      SOCKETS.delete socket
    end
  end
end
