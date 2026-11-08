require "json"
require "openssl"

module SemanticNotesSearcher
  class Indexer
    def initialize(@db : DB::Database, @embedding_repository = Repositories::Embeddings.new); end

    def index(dir : String)
      raise "Specified directory does not exist" unless Dir.exists?(dir)

      puts "Scanning Markdown files in #{dir}"
      puts "Found #{Dir.glob("#{dir}/**/*.md").size} Markdown files"
      puts "\n"
      puts "Generating Embeddings..."

      skipped = 0
      indexed = 0
      id = begin
        @db.query_one("SELECT id FROM notes ORDER BY ID DESC LIMIT 1", as: {Int32}) + 1
      rescue DB::NoResultsError
        0
      end
      Dir.glob("#{dir}/**/*.md").each do |md_file_path|
        prev_id, prev_content_hash = begin
          @db.query_one("SELECT id, content_hash FROM notes WHERE path = '#{md_file_path}' LIMIT 1", as: {Int32, String})
        rescue DB::NoResultsError
          {id, nil}
        end
        file_content = File.read(md_file_path)
        content_hash = sha256_hash(file_content)
        next skipped += 1 if prev_content_hash == content_hash
        if response = @embedding_repository.generate(file_content)
          indexed += 1
          note = Note.new(
            id: prev_id,
            path: md_file_path,
            embedding: response.embeddings.to_json,
            indexed_at: Time.utc.to_unix,
            content_hash: content_hash,
            model: response.model
          )

          if prev_content_hash
            @db.exec note.to_update_sql
          else
            @db.exec note.to_insert_sql
            id += 1
          end
        end
      rescue File::Error
        puts "[WARN] Could not read #{md_file_path}"
        skipped += 1
      end

      puts "Indexed: #{indexed}, Skipped: #{skipped}"
    end

    private def sha256_hash(input : String) : String
      OpenSSL::Digest.new("SHA256")
        .update(input)
        .hexfinal
    end
  end
end
