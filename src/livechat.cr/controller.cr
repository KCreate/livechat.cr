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
    property user_staging : Array(User)
    property rooms : Hash(String, Room)
    property user_room_lookup : Hash(User, Room | Nil.class)
    property socket_user_lookup : Hash(HTTP::WebSocket, User)

    # Used by event subscribers
    property lastUser : User?
    property lastRoom : Room?

    # Creates a new controller
    def initialize()
      @user_staging = [] of User
      @rooms = {} of String => Room
      @user_room_lookup = {} of User => Room | Nil.class
      @socket_user_lookup = {} of HTTP::WebSocket => User

      # Register all events used by this class
      register_event LivechatEvents::UserJoined
      register_event LivechatEvents::UserLeft
      register_event LivechatEvents::UserInfoChanged
      register_event LivechatEvents::RoomCreated
      register_event LivechatEvents::RoomDeleted

      # Broadcast status
      on LivechatEvents::UserJoined do
        user = @lastUser.not_nil!
        room = @user_room_lookup[user]

        if room.is_a? Room
          room.broadcast "#{user.name} joined"
        end
      end
    end

    # Handles *command* for a given *user*
    def command(comm : Command, user : User)
      type = comm.data["type"]
      case type
      when "change_name"
        puts "#{user.name} changed his name to: #{comm.data["name"]}"
        user.name = comm.data["name"].to_s

        # Invoke the UserInfoChanged event
        @lastUser = user
        invoke_event LivechatEvents::UserInfoChanged
      when "change_room"

        # Create the room if it doesn't exist already
        room = add_room comm["name"].to_s, user
        change_user_room user, room
      end
    end

    # Handles *command* for a given *socket*
    def command(comm : Command, socket : HTTP::WebSocket)
      user = user_for_socket? socket

      if user.is_a? User
        command comm, user
      end
    end

    # Adds a new room with *name* and *owner*
    # Returns the room
    def add_room(name : String, owner : User)
      if !@rooms[name]?.is_a? Room
        room = Room.new name, owner
        @rooms[name] = room

        # Invoke the RoomCreated Event
        @lastRoom = room
        invoke_event LivechatEvents::RoomCreated
      else
        room = @rooms[name]
      end

      room
    end

    # Puts *user* inside *room*
    def change_user_room(user : User, room : Room)

      # Check if the user is inside the staging area
      if user_staged user
        @user_staging.delete user
      else
        # Remove the player from his current room
        currentRoom = @user_room_lookup[user] as Room
        currentRoom.remove_user user
      end

      # Add the user to the new room
      room.add_user user
      @user_room_lookup[user] = room
    end

    # Puts *user* inside a room called *name*
    def change_user_room(user : User, name : String)
      room = add_room name, user
      change_user_room user, room
    end

    # Adds *socket* to the controller
    def add_socket(socket : HTTP::WebSocket)
      user = User.new SecureRandom.uuid, socket
      @user_staging << user
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

        # Check if the user is staged
        if user_staged user
          @user_staging.delete user
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
    private def user_staged(user : User)
      found = false
      @user_staging.each do |elem|
        if elem == user
          found = true
        end
      end
      found
    end
  end
end
