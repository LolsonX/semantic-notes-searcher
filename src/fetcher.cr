module SemanticNotesSearcher
  class Fetcher
    @notes : Array(Note)?
    @embedding_repository : Repositories::Embeddings

    def initialize(@db : DB::Database, @embedding_repository = Repositories::Embeddings.new); end

    def call(phrase : String, number_of_results : Int32 = 5)
      if phrase_embeddings = @embedding_repository.generate(phrase).embeddings
        distanced_notes = notes.map do |note|
          similarity = cosine_distance(phrase_embeddings.flatten, note.embeddings.flatten)
          next if similarity.nil?
          {similarity: similarity, note: note}
        end
        return distanced_notes.compact
          .select { |similarity_hash| similarity_hash[:similarity] > 0.6 }
          .sort_by! { |similarity_hash| -similarity_hash[:similarity] }
          .first(number_of_results)
      end

      [] of Hash(Symbol, Note | Float32)
    end

    private def notes : Array(Note)
      @notes ||= Array(Note).new.tap do |arr|
        @db.query("SELECT id, path,  content_hash, embedding, indexed_at, model FROM notes") do |result_set|
          result_set.each { arr << Note.from_db_result(result_set) }
        end
      end
    end

    private def cosine_distance(x : Array(Float32), y : Array(Float32)) : Float32?
      return if x.size != y.size

      mag_x = (x.sum { |val| val**2 }) ** 0.5
      mag_y = (y.sum { |val| val**2 }) ** 0.5
      dot_product = x.map_with_index { |value, idx| value * y[idx] }
        .sum

      dot_product / (mag_x * mag_y)
    end
  end
end
