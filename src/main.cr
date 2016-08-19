require "./livechat.cr/server.cr"
require "./livechat.cr/controller.cr"
require "./livechat.cr/events.cr"
require "./livechat.cr/command.cr"
require "json"
include Livechat

# Get a server instance
server = Server.new 3000

# Create a controller
controller = Controller.new server

# Once a connection opens, create a socket -> user pair
server.on LivechatEvents::SocketOpened do
  controller.add_socket server.lastSocket
end
server.on LivechatEvents::SocketMessage do

  # Try to create the command
  begin
    command = create_command server.lastMessage
  rescue ex
    puts "Invalid command issued!"
  end

  # If the command was recognized
  if command.is_a? Command
    controller.command command, server.lastSocket
  end
end
server.on LivechatEvents::SocketClosed do
  controller.remove_socket server.lastSocket
end

# Debug page
server.get "/status" do |context|
  response = ""
  controller.userBuffer.each do |user|
    response += "#{user.name} joined at: #{user.joinedAt}"
  end
  response
end

server.start
