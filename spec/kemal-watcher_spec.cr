require "./spec_helper"

describe Kemal do
  it "Kemal.watch handlers size" do
    Kemal.watch TEST_FILE
    # Are 7 because `Kemal.watch` add WebSocketHandler and WatcherHandler
    Kemal.config.handlers.size.should eq 7
  end
end
