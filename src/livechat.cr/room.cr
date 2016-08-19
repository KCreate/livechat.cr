require "./user.cr"
require "./events.cr"
require "events"

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
  end
end
