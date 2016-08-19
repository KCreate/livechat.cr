require "./livechat.cr/*"
require "json"
include Livechat

# Get a server instance
server = Server.new 3000

# Create a controller
controller = Controller.new

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

  # Append user information
  response += "<h1>Users</h1>"
  controller.user_room_lookup.each do |user, room|
    response += "<h3>#{user.name}</h3>"
    response += "<span>Joined at: #{user.joinedAt}</span><br>"

    # Check if the user is inside a room
    if room.is_a? Room
      response += "<span>In room: #{room.name}</span><br>"
    end
  end

  # Append room information
  response += "<h1>Rooms</h1>"
  controller.rooms.each do |roomname, room|
    response += "<h3>#{room.name}</h3>"
    response += "<span>Owner: #{room.owner.name}</span><br>"
    response += "<span>Amount of Contributions: #{room.contributions.size}</span><br>"
    response += "<span>Amount of Users: #{room.users.size}</span><br>"
  end

  response
end

server.start
