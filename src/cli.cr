module SemanticNotesSearcher
  module CLI
    SUPPORTED_COMMANDS = {
      "index <DIR>"         => "index given directory",
      "i <DIR>"             => "alias for index",
      "help"                => "print help message",
      "h"                   => "alias for help",
      "create_db"           => "setup database",
      "delete_db"           => "remove database",
      "search \"<PHRASE>\"" => "search indexed notes",
      "s \"<PHRASE>\""      => "alias for search",
      "stats"               => "index statistics",
    }

    NO_COMMAND = "no_command"

    def self.parse_command
      command = ARGV[0]?
      case command
      when "index", "i"
        if ARGV[1]?
          return {"index", ARGV[1]?}
        else
          handle_missing_argument("index")
        end
      when "help", "h"
        print_help
        exit(0)
      when "create_db"
        return {"create_db", nil}
      when "delete_db"
        return {"delete_db", nil}
      when "search", "s"
        if ARGV[1]?
          return {"search", ARGV[1]?}
        else
          handle_missing_argument("search")
        end
      when "stats"
        return {"status", nil}
      else
        handle_invalid_command(command || NO_COMMAND)
      end
    end

    def self.handle_missing_argument(command)
      if command == "index"
        puts "Missing argument for #{command}. Usage: index <DIR>"
      end
      exit(1)
    end

    def self.handle_invalid_command(command)
      if command == NO_COMMAND
        puts "Invalid usage"
      else
        puts "Invalid usage of #{command}"
      end

      print_help
      exit(1)
    end

    def self.print_help
      commands = SUPPORTED_COMMANDS.map do |command, description|
        "  #{command.ljust(20, ' ')}\t#{description}"
      end
      puts "\nAvailable commands:\n#{commands.join("\n")}"
    end
  end
end
