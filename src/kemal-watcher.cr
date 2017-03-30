require "./kemal-watcher/*"
require "secure_random"
require "watcher"

# Uses Watcher.watch shard to guard files
private def watcher(files)
  puts "  Your KemalBot is vigilant. beep-boop..."
  spawn do
    Watcher.watch files do |event|
      event.on_change do |files|
        files.each do |file, time|
          puts "  watching file: #{file}"
        end
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

  # Watch files and add WatcherHandler to Kemal handlers
  def self.watch(files)
    if Kemal.config.env == "production" || ENV["KEMAL_ENV"]? == "production"
      puts "Kemal.watch is intended for use in a development environment."
    end
    watcher files
    # add_handler WatcherHandler.new
  end

  # Start WebSocket server
  ws "/" + WEBSOCKETPATH do |socket|
    SOCKETS << socket
    socket.on_close do
      SOCKETS.delete socket
    end
  end

  # Instead of Kemal::Handler I'm using after_get
  # to check content_type == "text/html"
  # However, http://kemalcr.com/docs/filters/ says:
  # Important note: This should not be used by
  # plugins/addons, instead they should do all their
  # work in their own middleware.
  # In future releases I could improve the WatcherHandler
  # but for now it works.
  after_get do |env|
    if env.response.headers["Content-Type"] == "text/html"
      env.response.print <<-HTML
      \n<!-- Code injected by kemal-watcher -->
      <script type="text/javascript">
        // <![CDATA[  <-- For SVG support
        if ('WebSocket' in window) {
          (() => {
            var ws = new WebSocket("ws://" + location.host + "/#{WEBSOCKETPATH}");
            ws.onopen = () => {
              console.log("Connected to kemal-watcher");
            };
            ws.onmessage = (msg) => {
              if (msg.data == "reload") {
                window.location.reload();
              }
            };
            ws.onclose = () => {
              setTimeout(() => {
                window.location.reload();
              }, 2000);
            };
          })();
        }
        // ]]>
      </script>\n
      HTML
    end
  end
end
