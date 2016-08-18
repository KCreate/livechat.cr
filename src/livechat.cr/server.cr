# External dependencies
require "kemal"
require "events"

# Internal dependencies
require "./socket_user.cr"
require "./user.cr"
require "./socket_response.cr"

module Livechat

  # Spins up a new kemal instance and wraps around websocket events
  class Server
    include Events

    # Read only properties
    getter port : Int32
    getter sockets : Array(HTTP::WebSocket)
    getter lastItems : Hash(String, String | HTTP::WebSocket)

    def lastMessage
      @lastItems["message"] as String
    end

    def lastSocket
      @lastItems["socket"] as HTTP::WebSocket
    end

    # Define a new server instance
    # Listens on the specified *port*
    def initialize(@port = 3000)

      # Array of all current sockets
      @sockets = [] of HTTP::WebSocket

      # Dummy lastItems
      @lastItems = {} of String => String | HTTP::WebSocket

      # Listen for websocket connections on "/socket"
      ws "/socket" do |socket|
        @sockets << socket

        # Invoke the onopen event
        @lastItems["socket"] = socket
        invoke_event LivechatEvents::SocketOpened

        # Bind to onmessage and onclose event handlers
        socket.on_message do |message|
          @lastItems["message"] = message
          @lastItems["socket"] = socket

          # Invoke the onmessage event
          invoke_event LivechatEvents::SocketMessage
        end
        socket.on_close do |message|
          @lastItems["message"] = message
          @lastItems["socket"] = socket

          # Invoke the onclose event
          invoke_event LivechatEvents::SocketClosed

          # Remove the socket from the @sockets array
          @sockets.delete socket
        end
      end

      # Default route
      error 404 do |context|
        context.response.status_code = 501
        context.response.headers["content_type"] = "application/json"
        <<-RESPONSE
        {
          "ok": false,
          "errors": [
            "Route not implemented."
          ]
        }
        RESPONSE
      end

      # Set the port that kemal listens on
      Kemal.config.port = @port
    end

    # :nodoc:
    def get(path : String, &handler : HTTP::Server::Context -> String)
      ::get path, &handler
    end

    # :nodoc:
    def post(path : String, &handler : HTTP::Server::Context -> String)
      ::post path, &handler
    end

    # Start the server
    def start

      # Register some events
      register_event LivechatEvents::SocketOpened
      register_event LivechatEvents::SocketMessage
      register_event LivechatEvents::SocketClosed

      # Start kemal
      Kemal.run
    end

    # Stop the server
    def stop

      # Reset some stuff
      @lastItems = {} of String => String | HTTP::WebSocket
      @sockets.clear

      # Unregister all events
      unregister_event LivechatEvents::SocketOpened
      unregister_event LivechatEvents::SocketMessage
      unregister_event LivechatEvents::SocketClose

      # Shut down Kemal
      Kemal.config.server.not_nil!.close
    end

    # Closes the connection to a socket,
    # optionally passing a SocketResponse object
    def close_connection(socket : HTTP::WebSocket)
      socket.close
    end

    # Closes the connection to a user,
    # optionally passing a SocketResponse object
    def close_connection(user : User)
      close_connection SocketUser.socket_for_user?(user).not_nil!
    end
  end
end
