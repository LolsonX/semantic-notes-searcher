module SemanticNotesSearcher
  class Note
    TABLE_NAME = "notes"
    getter :id, :path

    @embeddings : Array(Array(Float32))?

    def initialize(
      @id : Int32, @path : String, @content_hash : String, @embedding : String, @indexed_at : Int64, @model : String,
    )
    end

    def embeddings : Array(Array(Float32))
      @embeddings ||= JSON.parse(@embedding).as_a.map(&.as_a.map(&.as_f32))
    end

    def to_insert_sql
      <<-SQL
        INSERT INTO #{TABLE_NAME}
        (id, path, content_hash, embedding, model, indexed_at)
        VALUES
        (#{@id}, '#{@path}', '#{@content_hash}', '#{@embedding}', '#{@model}', #{@indexed_at})
        SQL
    end

    def to_update_sql
      <<-SQL
        UPDATE #{TABLE_NAME}
        SET path = '#{@path}', content_hash = '#{@content_hash}', embedding = '#{@embedding}', model = '#{@model}', indexed_at = #{@indexed_at}
        WHERE id = #{@id}
        SQL
    end

    def self.from_db_result(result)
      id, path, content_hash, embedding, indexed_at, model = result.read(Int32, String, String, String, Int64, String)
      new(id: id, path: path, content_hash: content_hash, embedding: embedding, indexed_at: indexed_at, model: model)
    end
  end
end
