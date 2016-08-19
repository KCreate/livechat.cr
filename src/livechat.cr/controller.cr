# External dependencies
require "json"
require "events"

# Internal dependencies
require "./user.cr"
require "./room.cr"
require "./contribution.cr"
require "./command.cr"

module Livechat

  # Controls the livechat
  class Controller
    include Events

    # Used to store users that are in no room yet
    property userBuffer : Array(User)
    property rooms : Array(Room)
    property server : Server
    property user_room_lookup : Hash(User, Room | Nil.class)
    property socket_user_lookup : Hash(HTTP::WebSocket, User)

    # Used by event subscribers
    property lastUser : User?

    # Creates a new controller
    def initialize(@server)
      @userBuffer = [] of User
      @rooms = [] of Room
      @user_room_lookup = {} of User => Room | Nil.class
      @socket_user_lookup = {} of HTTP::WebSocket => User

      register_event LivechatEvents::UserJoined
      register_event LivechatEvents::UserLeft
      register_event LivechatEvents::UserInfoChanged
    end

    # Handles *command* for a given *user*
    def command(comm : Command, user : User)
      type = comm.data["type"]
      case type
      when "change_name"
        puts "#{user.name} changed his name to: #{comm.data["name"]}"
        user.name = comm.data["name"].to_s
      when "change_room"
        puts "#{user.name} changed to room: #{comm.data["name"]}"
      end
    end

    # Handles *command* for a given *socket*
    def command(comm : Command, socket : HTTP::WebSocket)
      user = user_for_socket? socket

      if user.is_a? User
        command comm, user
      end
    end

    # Adds *socket* to the controller
    def add_socket(socket : HTTP::WebSocket)
      user = User.new SecureRandom.uuid, socket
      @userBuffer << user
      @user_room_lookup[user] = Nil
      @socket_user_lookup[socket] = user

      # Invoke the event
      @lastUser = user
      invoke_event LivechatEvents::UserJoined
    end

    # Removes the *socket* from the controller
    def remove_socket(socket : HTTP::WebSocket)
      user = user_for_socket? socket

      # If the user exists inside the controller
      if user.is_a? User
        user = user.not_nil!

        # Check if the user is inside the user buffer
        if user_is_in_buffer user
          @userBuffer.delete user
        else

          # Remove the user from it's room
          room = @user_room_lookup[user] as Room
          room.remove_user user
        end

        @user_room_lookup.delete user
        @socket_user_lookup.delete socket

        # Set the @lastUser prop for events to use
        @lastUser = user
        invoke_event LivechatEvents::UserLeft
      end
    end

    # Returns the user for a given *socket*
    def user_for_socket?(socket : HTTP::WebSocket)
      @socket_user_lookup[socket]
    end

    # Returns true if *user* is inside the userBuffer
    private def user_is_in_buffer(user : User)
      found = false
      @userBuffer.each do |elem|
        if elem == user
          found = true
        end
      end
      found
    end
  end
end
