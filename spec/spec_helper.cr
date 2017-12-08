require "spec"
require "../src/kemal-watcher"

TEST_FILE = "src/kemal-watcher.cr"

OUTPUT = <<-HTML
<script type=\"text/javascript\">  if ('WebSocket' in window) {    (() => {      var protocol = window.location.protocol === 'http:' ? 'ws://' : 'wss://';      var address = protocol + window.location.host + window.location.pathname + `/${WEBSOCKET_PATH}`;      var socket = new WebSocket(address);      ws.onopen = () => {        console.log(\"Connected to kemal-watcher\");      };      ws.onmessage = (msg) => {        if (msg.data == \"reload\") {          window.location.reload();        }      };      ws.onclose = () => {        setTimeout(() => {          window.location.reload();        }, 2000);      };    })();  }</script>
HTML