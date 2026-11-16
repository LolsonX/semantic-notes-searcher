module SemanticNotesSearcher
  module Models
    @[Table(name: "notes")]
    class Note
      include Queryable
      @[Column(name: "id", primary_key: true)]
      property id : Int32

      @[Column(name: "path")]
      property path : String

      @[Column(name: "embedding")]
      property embedding : String

      @[Column(name: "indexed_at")]
      property indexed_at : Int64

      @[Column(name: "content_hash")]
      property content_hash : String

      @[Column(name: "model")]
      property model : String

      @embeddings : Array(Array(Float32))?

      def self.from_db_result(result)
        id, path, content_hash, embedding, indexed_at, model = result.read(Int32, String, String, String, Int64, String)
        new(id: id, path: path, content_hash: content_hash, embedding: embedding, indexed_at: indexed_at, model: model)
      end

      def initialize(@id, @path, @embedding, @indexed_at, @content_hash, @model); end

      def embeddings : Array(Array(Float32))
        @embeddings ||= JSON.parse(@embedding).as_a.map(&.as_a.map(&.as_f32))
      end
    end
  end
end
