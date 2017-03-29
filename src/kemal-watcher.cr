require "./kemal-watcher/*"
require "secure_random"
require "watcher"

# Uses Watcher.watch shard to guard files
private def watcher(files)
  spawn do
    Watcher.watch files do |event|
      event.on_change do
        Kemal.handle_change
      end
    end
  end
  add_handler WatcherHandler.new
end

module Kemal

  SOCKETS = [] of HTTP::WebSocket

  WEBSOCKETPATH = SecureRandom.hex(4)

  FILES = [] of String

  # Handle change when event.on_change and
  # send reload message to all clients
  def handle_change
    SOCKETS.each do |socket|
      socket.send "reload"
    end
  end

  # Watch files in a concurrent way
  def self.watch(files)
    watcher(files)
  end

  # Start WebSocket server
  ws "/" + WEBSOCKETPATH do |socket|
    SOCKETS << socket
    socket.on_close do
      SOCKETS.delete socket
    end
  end
end
