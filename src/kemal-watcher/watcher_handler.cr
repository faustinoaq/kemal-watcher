module Kemal
  # The right way to handle context is Kemal::Handler
  # but I can not check response content type easily
  # In future release the code below could change
  # class WatcherHandler < Kemal::Handler
  #   def call(context)
  #     call_next context
  #   end
  # end

  # Handle change when event.on_change and
  # send reload message to all clients
  def self.handle_change
    SOCKETS.each do |socket|
      socket.send "reload"
    end
  end

  # Instead of Kemal::Handler I'm using a filter handler
  # to check content_type == "text/html"
  # However, http://kemalcr.com/docs/filters/ says:
  # Important note: This should not be used by
  # plugins/addons, instead they should do all their
  # work in their own middleware.
  # In future releases I could improve the WatcherHandler
  # but for now it works.
  def self.filter_handler
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
end
