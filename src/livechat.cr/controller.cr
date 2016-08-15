# External dependencies
require "json"
require "events"

# Internal dependencies
require "./user.cr"
require "./room.cr"
require "./contribution.cr"

module Livechat

  # Controls the livechat
  class Controller

    property rooms : Array(Room)

    # Creates a new controller
    def initialize
      @rooms = [] of Room
    end

    # Handles a *command* for a given *user*
    def command(command : JSON::Any, user : User)
    end
  end
end
