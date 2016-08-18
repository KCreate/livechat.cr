require "./livechat.cr/*"
require "json"
include Livechat
include SecureRandom

# Get a server instance
server = Server.new 3000

# Create a controller
controller = Controller.new server

# Once a connection opens, create a socket -> user pair
server.on LivechatEvents::SocketOpened do

  # Create a new user
  user = User.new SecureRandom.uuid

  # Add the pair
  SocketUser.add_pair user, server.lastSocket
end
server.on LivechatEvents::SocketMessage do

  # Try to create the command
  begin
    command = create_command server.lastMessage
  rescue ex
    response = SocketResponse.new false, ResponseType::Error
    response.errors << ex.message.not_nil! unless ex.message.is_a? Nil

    server.lastSocket.send response.to_json
  end

  # If the command is correct
  if !command.is_a? Nil

    # Create the command and user objects
    user = SocketUser.user_for_socket?(server.lastSocket)

    # Run the command with the given user
    controller.command command, user
  end
end

server.on LivechatEvents::SocketClosed do

  # Remove the pair
  SocketUser.remove_socket server.lastSocket
end

server.get "/status" do |context|
  context.response.headers["Content-Type"] = "text/plain"
  response = ""
  SocketUser.all_users.each do |user|
    response += "#{user.name} \n"
  end
  response
end

server.start
