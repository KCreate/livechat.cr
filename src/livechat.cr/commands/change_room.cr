require "../*"

module Livechat

  # Changes the room a player is in
  class ChangeRoomCommand < Command
    def properties
      {
        "name" => String
      }
    end
  end
end
