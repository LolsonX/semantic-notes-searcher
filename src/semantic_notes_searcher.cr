# Semantic Notes Search is a command-line application written in Crystal that allows users to search local Markdown
# notes using natural language.
# Unlike traditional keyword search, the application uses AI embeddings to identify notes that are semantically related
# to the user's query, even when they don't contain the exact search terms.
# For example, searching for "How do I secure my API?" should also find notes discussing JWT authentication, access tokens, and authorization.

require "db"
require "sqlite3"
require "./cli"
require "./note"
require "./repositories"
require "./fetcher"
require "./indexer"

module SemanticNotesSearcher
  DB_HOST = "sqlite3://./.sns/index.db"

  def self.run
    command = CLI.parse_command
    case command[0]
    when "index"
      if directory = command[1]
        DB.open(DB_HOST) do |database_connection|
          Indexer.new(database_connection).index(directory)
        end
      end
    when "search"
      if phrase = command[1]
        DB.open(DB_HOST) do |database_connection|
          results = Fetcher.new(db: database_connection).call(phrase)
          if results.size.positive?
            results.each_with_index(1) do |note_with_similarity, index|
              similarity = note_with_similarity[:similarity].as(Float32)
              note = note_with_similarity[:note].as(Note)
              preview = File.read(note.path)[0..150]
              puts "#{index}. #{note.path}"
              puts "Similarity: #{similarity}"
              puts "#{"PREVIEW".rjust(75, '-').ljust(150, '-')}\n\n"
              preview.each_line.with_index do |line, line_number|
                puts "#{line_number.to_s.ljust(3, ' ')}|\t#{line}"
              end
              puts "\n#{"-" * 150}\n\n"
            end
          else
            puts "Did not find any note using phrase #{phrase}"
          end
        end
      end
    when "status"
      DB.open(DB_HOST) do |database_connection|
        number_of_notes = database_connection.query_one("SELECT COUNT(*) FROM notes", as: Int64)
        puts "Number of indexed notes: #{number_of_notes}"
      end
    when "create_db"
      Dir.mkdir_p(".sns") unless Dir.exists?(".sns")
      DB.open(DB_HOST) do |database_connection|
        database_connection.exec <<-SQL
            CREATE TABLE IF NOT EXISTS notes (
              id INTEGER PRIMARY KEY,
              path TEXT UNIQUE NOT NULL,
              content_hash TEXT NOT NULL,
              embedding TEXT NOT NULL,
              model TEXT NOT NULL,
              indexed_at INTEGER NOT NULL
          );
          SQL
      end
    when "delete_db"
      DB.open(DB_HOST) do |database_connection|
        database_connection.exec <<-SQL
          DROP TABLE IF EXISTS notes;
          SQL
      end
    else
      exit(0)
    end
  end
end

SemanticNotesSearcher.run
