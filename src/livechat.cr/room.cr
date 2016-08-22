require "events"
require "./*"

module Livechat
  class Room
    include Events

    # Regular properties
    property users : Array(User)
    property owner : User
    property name : String
    property contributions : Array(Contribution)

    # Temporary properties you should read from via event handlers
    property lastUser : User?
    property lastContribution : Contribution?

    # Creates a new room,
    # gives it a *name* and an *owner*
    def initialize(@name, @owner)
      @users = [] of User
      @contributions = [] of Contribution

      # Register some events
      register_event LivechatEvents::UserJoinedRoom
      register_event LivechatEvents::UserLeftRoom
      register_event LivechatEvents::ContributionAdded
      register_event LivechatEvents::RoomCleared
      register_event LivechatEvents::RoomInfoChanged

      # Broadcasts for UserJoinedRoom and UserLeftRoom
      on [LivechatEvents::UserJoinedRoom, LivechatEvents::UserLeftRoom] do
        broadcast_userlist
      end

      # Broadcasts for the UserInfoChanged event on the user
      on LivechatEvents::UserJoinedRoom do
        user = @lastUser.not_nil!
        user.on LivechatEvents::UserInfoChanged do
          broadcast_userinfo user
        end
      end

      on LivechatEvents::UserLeftRoom do
        user = @lastUser.not_nil!
        user.clear_handlers LivechatEvents::UserInfoChanged
      end
    end

    # Add a *user* to the current room
    def add_user(user : User)
      @users << user
      @lastUser = user
      invoke_event LivechatEvents::UserJoinedRoom
    end

    # Remove a *user* from the current room
    def remove_user(user : User)
      @users.delete user
      @lastUser = user
      invoke_event LivechatEvents::UserLeftRoom
    end

    # Adds a *contribution* to the room
    def add_contribution(contribution : Contribution)
      @contributions << contribution

      invoke_event LivechatEvents::ContributionAdded
    end

    # Removes all contributions from the current room
    def clear(user)
      if user.uid == @owner.uid
        @contributions.clear

        invoke_event LivechatEvents::RoomCleared
      end
    end

    # Broadcasts the info of *user* to all users
    def broadcast_userinfo(user : User)
      broadcast String.build { |str|
        str << "USERINFO\n"
        str << "#{user.uid}\n"
        str << "#{user.name}\n"
        str << "USERINFOEND"
      }
    end

    # Broadcasts the info of all users to all users
    def broadcast_userinfo
      @users.each do |user|
        broadcast_userinfo user
      end
    end

    # Broadcasts the list of all users to all users
    def broadcast_userlist
      broadcast String.build { |str|
        str << "USERLIST\n"
        @users.each do |user|
          str << "#{user.uid}\n"
          str << "#{user.name}\n"
        end
        str << "USERLISTEND"
      }
    end

    # Broadcasts *message* to all users inside the rooms
    def broadcast(message : String)
      @users.each do |user|
        user.send message
      end
    end

    # Allows calling broadcast via do
    # DSL
    def broadcast
      broadcast yield
    end
  end
end
