require "json"

module Livechat

  # Return an instance of the command
  # determined by the type field of the raw command
  def create_command(raw : String)
    begin
      raw = JSON.parse raw as String
    rescue
      raise ParseFailedException.new
    end

    # Get the type
    type = raw["type"]

    case type
    when "change_name"
      ChangeNameCommand.new raw
    when "close"
      CloseCommand.new raw
    else
      raise UnknownCommandException.new
    end
  end

  # Abstract command definition
  # contains some basic parsing functions
  abstract class Command

    getter data : JSON::Any
    data = JSON.parse "\"dummy data\""

    # Subclasses have to implement this
    abstract def properties

    # Create a new command from a raw json string
    def initialize(raw : String)
      json = JSON.parse raw
      initialize JSON.parse raw
    end

    # Create a new command from a JSON::Any object
    def initialize(json : JSON::Any)

      # Raise if there is no type
      if json["type"].is_a? Nil
        raise NoTypeException.new
      end

      # Check if all required props are set
      if !correct_props json
        raise MissingPropsException.new
      end

      @data = json
    end

    # Checks if a given command has all required parameters
    private def correct_props(command)
      correctprops = true

      # Check if all props are set and are of the right type
      properties.each do |key, value|
        if command[key].is_a? Nil
          correctprops = false
        end

        if typeof(command[key]) != value
          correctpros = false
        end
      end

      correctprops
    end
  end

  # Raised when a raw string could not be parsed as JSON
  class ParseFailedException < Exception
    def message
      "Failed to parse json"
    end
  end

  # Raised when a command doesn't specify a type
  class NoTypeException < Exception
    def message
      "The command doesn't have a type specified"
    end
  end

  # Raised when a command is not known
  class UnknownCommandException < Exception
    def message
      "Unknown command"
    end
  end

  # Raised when a command is missing some props
  class MissingPropsException < Exception
    def message
      "There are missing properties"
    end
  end
end

module Livechat
  abstract class Command
    abstract def properties
  end
end

require "./commands/*"
