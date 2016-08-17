require "../command.cr"

module Livechat

  # Changes the name of a player
  class ChangeNameCommand < Command
    def properties
      {
        "name" => String
      }
    end
  end
end
