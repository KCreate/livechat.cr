require "json"
require "./contribution.cr"
require "./room.cr"
require "./user.cr"

module Livechat

  # External response types
  enum ResponseType
    NewContribution
    UserJoined
    UserLeft
    UserNameChanged
    RoomNameChanged
    RoomCleared
    YouGotKicked
    Error
  end

  # Defines the response the socket send back to the client
  class SocketResponse

    # Timestamp
    getter timestamp : UInt64

    # Properties every response needs to have
    property ok : Bool
    property errors : Array(String)?
    property type : ResponseType

    # Optional properties
    property contributions : Contribution?
    property user : User?
    property room : Room?

    def initialize(@ok, @type)
      @timestamp = Time.now.epoch as UInt64
    end
  end
end
