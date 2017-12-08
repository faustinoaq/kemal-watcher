module Kemal
  # The right way to handle context is Kemal::Handler
  # but I can not check response content type easily
  # In future release the code below could change
  class WatcherHandler
    def call(context)
      if context.response.headers["Content-Type"] == "text/html"
        context.response.print <<-HTML
        <script type="text/javascript">
        if ('WebSocket' in window) {
          (() => {
            var protocol = window.location.protocol === 'http:' ? 'ws://' : 'wss://';
            var address = protocol + window.location.host + window.location.pathname + `#{WEBSOCKETPATH}`;
            var ws = new WebSocket(address);
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
        </script>
        HTML
      end
    end
  end

  # Handle change when event.on_change and
  # send reload message to all clients
  private def self.handle_change
    SOCKETS.each do |socket|
      socket.send "reload"
    end
  end
end
