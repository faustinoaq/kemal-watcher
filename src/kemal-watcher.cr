require "kemal"
require "watcher"
require "secure_random"

require "./kemal-watcher/*"

module Kemal
  SOCKETS       = [] of HTTP::WebSocket
  WEBSOCKETPATH = SecureRandom.hex 4

  # Uses Watcher.watch shard to guard files
  def self.watcher(files)
    spawn do
      puts "  Your KemalBot is vigilant. beep-boop..."
      watch files do |event|
        event.on_change do |files|
          files.each do |file, time|
            puts "  watching file: #{file}"
          end
          handle_change
        end
      end
    end
  end

  # Watch files and add WatcherHandler to Kemal handlers
  def self.watch(files)
    if Kemal.config.env == "production" || ENV["KEMAL_ENV"]? == "production"
      puts "Kemal.watch is intended for use in a development environment."
    end
    # add_handler WatcherHandler.new
    websocket_server
    filter_handler
    watcher files
  end

  # Start WebSocket server
  def self.websocket_server
    ws "/" + WEBSOCKETPATH do |socket|
      SOCKETS << socket
      socket.on_close do
        SOCKETS.delete socket
      end
    end
  end
end
