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
end

module Kemal
  SOCKETS       = [] of HTTP::WebSocket
  WEBSOCKETPATH = SecureRandom.hex 4

  # Handle change when event.on_change and
  # send reload message to all clients
  def self.handle_change
    SOCKETS.each do |socket|
      socket.send "reload"
    end
  end

  {% if env("KEMAL_ENV") == "production" %}
    def self.watch(files)
      puts "kemal-watcher doesn't work in production environments"
    end
  {% else %}
    # Watch files and add WatcherHandler to Kemal handlers
    def self.watch(files)
        watcher files
        add_handler WatcherHandler.new
    end

    # Start WebSocket server
    ws "/" + WEBSOCKETPATH do |socket|
      SOCKETS << socket
      socket.on_close do
        SOCKETS.delete socket
      end
    end
  {% end %}
end
