require "../*"

module Livechat

  # Adds a contribution to a room
  class AddContributionCommand < Command
    def properties
      {
        "contributionType" => String,
        "message" => String
      }
    end
  end
end
