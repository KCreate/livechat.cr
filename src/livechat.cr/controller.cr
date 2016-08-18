# External dependencies
require "json"
require "events"

# Internal dependencies
require "./user.cr"
require "./room.cr"
require "./contribution.cr"
require "./socket_user.cr"
require "./command.cr"

module Livechat

  # Controls the livechat
  class Controller

    property rooms : Array(Room)
    property server : Server
    property user_room_lookup : Hash(User, Room)

    # Creates a new controller
    def initialize(@server)
      @rooms = [] of Room
    end

    # Handles a *command* for a given *user*
    def command(command : Command, user : User)
      type = command.data["type"]
      case type
      when "change_name"
        puts "#{user.name} changed his name to: #{command.data["name"]}"
        user.name = command.data["name"].to_s
      end
    end

    # Broadcast a string to all users inside a room
    def broadcast(response : String, room : Room)

    end
  end
end
