module Livechat

  # Internal events
  enum LivechatEvents

    # Sockets
    SocketOpened
    SocketClosed
    SocketMessage

    # Users
    UserJoined
    UserLeft
    UserInfoChanged

    # Rooms
    ContributionAdded
    RoomInfoChanged
    RoomCleared
    RoomCreated
    RoomDeleted
    UserJoinedRoom
    UserLeftRoom

    # Misc & Debug
    Broadcast
  end
end
