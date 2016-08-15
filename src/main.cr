require "./livechat.cr/*"
require "json"
include Livechat
include SecureRandom

# Create a controller
controller = Controller.new

# Get a server instance
server = Server.new 3000

# Once a connection opens, create a socket -> user pair
server.on LivechatEvents::SocketOpened do

  # Create a new user
  user = User.new SecureRandom.uuid

  # Add the pair
  SocketUser.add_pair user, server.lastSocket.not_nil!
end
server.on LivechatEvents::SocketMessage do

  begin
    command = JSON.parse server.lastMessage.not_nil!
  rescue
    puts "that is not json!!"
    puts "---"
    puts server.lastMessage.not_nil!
    puts "---"

    next
  end

  # JSON.parse didn't throw so command is valid JSON
  command = command.not_nil!

  # Get the user for the current socket
  user = SocketUser.user_for_socket?(server.lastSocket.not_nil!)

  # Run the command with the given user
  controller.command command, user
end

server.on LivechatEvents::SocketClosed do

  # Remove the pair
  SocketUser.remove_socket server.lastSocket.not_nil!
end

server.get "/status" do |context|

  context.response.headers["Content-Type"] = "text/plain"

  response = ""
  SocketUser.all_users.each do |user|
    response += "#{user.uid} \n"
  end
  response
end

server.start
