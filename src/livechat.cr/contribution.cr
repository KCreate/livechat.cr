require "./user.cr"

module Livechat
  enum ContributionType
    Message
  end

  class Contribution
    @user : User
    @type : ContributionType
    property message : String?

    def initialize(@user, @type)
    end

    def initialize(@user, @type, @message)
    end
  end
end
