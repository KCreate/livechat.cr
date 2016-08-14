module Livechat
  class User

    alias RecStringHash = Hash(String, String | RecStringHash)

    property uid : String
    property name : String?
    property permissions : RecStringHash

    # Set default permissions
    @permissions = {
      "admin" => false,
      "canReset" => false,
      "canOpen" => true,
      "canKick" => false
    }

    # Takes a *uid* and an optional Hash to overwrite default permissions
    def initialize(@uid, permissions : RecStringHash)

      # Overwrite each key with the value set in *permissions*
      permissions.each do |key, value|
        @permissions[key] = value
      end
    end
  end
end
