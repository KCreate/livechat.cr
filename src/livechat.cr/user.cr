require "events"
require "./*"

module Livechat
  class User
    include Events

    alias Permissions = Hash(String, Bool)

    property uid : String
    @name : String?
    property permissions : Permissions
    property socket : HTTP::WebSocket
    property joinedAt : Int64

    # Set default permissions
    @permissions = {
      "admin" => false,
      "canReset" => false,
      "canOpen" => true,
      "canKick" => false
    }

    # Takes a *uid* and an optional Hash to overwrite default permissions
    def initialize(@uid, @socket, permissions : Permissions = {} of String => Bool)

      # Overwrite each key with the value set in *permissions*
      permissions.each do |key, value|
        @permissions[key] = value
      end

      # Set joinedAt
      @joinedAt = Time.now.epoch

      # Register events
      register_event LivechatEvents::UserInfoChanged
    end

    # Returns the name of the user
    # if the user has no name, the uid will be returned
    def name
      if @name
        @name
      else
        @uid
      end
    end

    # :nodoc:
    def name=(name : String)
      @name = name
      invoke_event LivechatEvents::UserInfoChanged
    end

    # Send *message* to the user
    def send(message : String)
      @socket.send message
    end
  end
end
