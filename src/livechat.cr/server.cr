require "kemal"
require "events"

module Livechat
  # Spins up a new kemal instance and wraps around websocket events
  class Server
    include Events

    # Read only properties
    getter port : Int32
    getter lastMessage : String?
    getter lastSocket : HTTP::WebSocket?
    getter sockets : Array(HTTP::WebSocket)

    # Define a new server instance
    # Listens on the specified *port*
    def initialize(@port = 3000)

      # Array of all current sockets
      @sockets = [] of HTTP::WebSocket

      # Listen for websocket connections on "/socket"
      ws "/socket" do |socket|
        @sockets << socket

        # Invoke the onopen event
        @lastSocket = socket
        invoke_event "open"

        # Bind to onmessage and onclose event handlers
        socket.on_message do |message|
          @lastMessage = message
          @lastSocket = socket

          # Invoke the onmessage event
          invoke_event "message"
        end
        socket.on_close do |message|
          @lastMessage = message
          @lastSocket = socket

          # Invoke the onclose event
          invoke_event "close"

          # Remove the socket from the @sockets array
          @sockets.delete socket
        end
      end

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
      register_event "open"
      register_event "message"
      register_event "close"

      # Start kemal
      Kemal.run
    end

    # Stop the server
    def stop

      # Reset some stuff
      @lastMessage = Nil
      @lastSocket = Nil
      @sockets.clear

      # Unregister all events
      unregister_event "open"
      unregister_event "message"
      unregister_event "close"

      # Shut down Kemal
      Kemal.config.server.not_nil!.close
    end
  end
end
