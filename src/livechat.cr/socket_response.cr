require "json"
require "./*"

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
    YouClosed
    Error
  end

  # A response sent back to the client over a HTTP::WebSocket
  struct SocketResponse
    property timestamp : Int64
    property ok : Bool
    property errors : Array(String)
    property type : ResponseType
    property data : JSON::Any?

    def initialize(@ok, @type)
      @timestamp = Time.now.epoch
      @errors = [] of String
    end

    JSON.mapping({
      timestamp: { type: Int64 },
      ok: { type: Bool },
      errors: { type: Array(String) },
      type: { type: ResponseType },
      data: { type: JSON::Any, nilable: true }
    })
  end
end
