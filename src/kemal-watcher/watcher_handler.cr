require "kemal"

module Kemal
  class WatcherHandler < Kemal::Handler
    def call(context)
      context.response.print <<-HTML
      <!-- Code injected by kemal-watcher -->
      <script type="text/javascript">
        // <![CDATA[  <-- For SVG support
        if ('WebSocket' in window) {
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
        }
        // ]]>
      </script>\n
      HTML
      call_next context
    end
  end
end
