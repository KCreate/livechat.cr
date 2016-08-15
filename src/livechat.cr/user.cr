module Livechat
  class User

    alias Permissions = Hash(String, Bool)

    property uid : String
    property name : String?
    property permissions : Permissions

    # Set default permissions
    @permissions = {
      "admin" => false,
      "canReset" => false,
      "canOpen" => true,
      "canKick" => false
    }

    # Takes a *uid* and an optional Hash to overwrite default permissions
    def initialize(@uid, permissions : Permissions = {} of String => Bool)

      # Overwrite each key with the value set in *permissions*
      permissions.each do |key, value|
        @permissions[key] = value
      end
    end
  end
end
