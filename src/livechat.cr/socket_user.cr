require "./user.cr"

module Livechat

  # Keeps track of the HTTP::WebSocket -> Livechat::User pairs
  class SocketUser

    # The socket -> user pairs
    @@pairs = {} of HTTP::WebSocket => User

    # :nodoc:
    def self.pairs
      @@pairs
    end

    # Adds a user, socket pair
    def self.add_pair(user : User, socket : HTTP::WebSocket)
      @@pairs[socket] = user
    end

    # Removes a pair by it's *socket*
    def self.remove_socket(socket : HTTP::WebSocket)
      @@pairs.delete socket
    end

    # Removes a pair by it's *user*
    def self.remove_user(user : User)
      @@pairs.delete socket_for_user? user
    end

    # Returns the user for a given *socket*
    def self.user_for_socket?(socket : HTTP::WebSocket)
      @@pairs[socket]
    end

    # Returns the socket for a given *user*
    def self.socket_for_user?(user : User)
      socket = Nil
      @@pairs.each do |key, value|
        if value == user
          socket = key
          break
        end
      end

      if socket.is_a? Nil
        socket as Nil
      else
        socket as HTTP::WebSocket
      end
    end

    # Returns all users as Array(User)
    def self.all_users
      users = [] of User
      @@pairs.each_value do |value|
        users << value
      end
      users
    end

    # Returns all sockets as Array(HTTP::WebSocket)
    def self.all_sockets
      sockets = [] of HTTP::WebSocket
      @@pairs.each_key do |key|
        sockets << key
      end
      sockets
    end
  end
end
