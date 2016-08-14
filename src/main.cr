require "./livechat.cr/*"

module Livechat
  # Get a server instance
  server = Server.new 3000
  server.on "message" do
    puts server.lastMessage
  end

  server.get "/status" do
    "HELLOOOO"
  end

  server.start
end
