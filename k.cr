require "kemal"

require "./src/kemal-watcher"

get "/" do
end

Kemal.watch("./*")

Kemal.run
