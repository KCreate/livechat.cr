require "./user.cr"

module Livechat
  enum ContributionType
    Message
  end

  class Contribution
    property user : User
    property type : ContributionType
    property message : String?

    def initialize(@user, @type)
    end

    def initialize(@user, @type, @message)
    end
  end
end
