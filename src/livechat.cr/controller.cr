# External dependencies
require "json"
require "events"

# Internal dependencies
require "./user.cr"
require "./room.cr"
require "./contribution.cr"
require "./socket_user.cr"
require "./socket_response.cr"
require "./command.cr"

module Livechat

  # Controls the livechat
  class Controller

    property rooms : Array(Room)
    property server : Server

    # Creates a new controller
    def initialize(@server)
      @rooms = [] of Room
    end

    # Handles a *command* for a given *user*
    def command(command : Command, user : User)
      puts command
      puts user
    end
  end
end
