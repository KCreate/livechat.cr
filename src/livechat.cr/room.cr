require "./user.cr"
require "events"

module Livechat
  class Room

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
      register_event "userjoined"
      register_event "userleft"
      register_event "contributionadded"
      register_event "contributionscleared"
      register_event "namechanged"
    end

    # Adds a *contribution* to the room
    def add_contribution(contribution : Contribution)
      @contributions << contribution
    end

    # Removes all contributions from the current room
    def clear(user)
      if user.uid == @owner.uid
        @contributions.clear
      end
    end
  end
end
