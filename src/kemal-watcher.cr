require "kemal"
require "watcher"

require "./kemal-watcher/*"

module Kemal
  SOCKETS       = [] of HTTP::WebSocket
  WEBSOCKETPATH = rand(0x10000000).to_s(36)

  # Uses Watcher.watch shard to guard files
  private def self.watcher(files)
    spawn do
      puts "  Your KemalBot is vigilant. beep-boop..."
      watch files do |event|
        event.on_change do |files|
          files.each do |file, data|
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
    websocket_server
    Kemal::FilterHandler::INSTANCE.after("GET", "*") do |context|
      WatcherHandler.new.call(context)
    end
    watcher files
  end

  # Start WebSocket server
  private def self.websocket_server
    ws "/" + WEBSOCKETPATH do |socket|
      SOCKETS << socket
      socket.on_close do
        SOCKETS.delete socket
      end
    end
  end
end
