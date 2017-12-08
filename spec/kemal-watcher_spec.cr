require "./spec_helper"

describe Kemal do
  it "Kemal.watch check client output" do
    get "/" do |env|
      ""
    end
    Kemal.watch TEST_FILE
    spawn do
      Kemal.run
    end
    sleep 1
    response = HTTP::Client.get "http://localhost:3000"
    Kemal.stop
    response.body.lines.join.should contain "Connected to kemal-watcher"
  end
end
