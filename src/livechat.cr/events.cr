module Livechat

  # Internal events
  enum LivechatEvents

    # Sockets
    SocketOpened
    SocketClosed
    SocketMessage

    # Contributions
    ContributionAdded

    # Users
    UserJoined
    UserLeft
    UserInfoChanged

    # Rooms
    RoomInfoChanged
    RoomCleared

    # Misc & Debug
    Broadcast
  end
end
