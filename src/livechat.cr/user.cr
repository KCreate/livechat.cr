module Livechat
  class User

    alias Permissions = Hash(String, Bool)

    property uid : String
    property name : String?
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

    # Send *message* to the user
    def send(message : String)
      @socket.send message
    end
  end
end
