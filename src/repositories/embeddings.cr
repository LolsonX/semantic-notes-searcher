require "http/client"
require "json"

module SemanticNotesSearcher
  module Repositories
    class Embeddings < Base
      EMBEDDING_MODEL      = "nomic-embed-text"
      EMBEDDING_MODEL_HOST = "localhost"
      EMBEDDING_MODEL_PORT = 11434
      EMBEDDING_ENDPOINT   = "/api/embed"

      @client : HTTP::Client?

      private class Request
        include JSON::Serializable

        getter input : String
        getter model : String

        def initialize(@input : String, @model : String); end

        def self.build(input : String, model : String)
          new(input, model).to_json
        end
      end

      private class Response
        include JSON::Serializable
        getter embeddings : Array(Array(Float32))
        getter model : String

        def initialize(@embeddings : Array(Array(Float32)), @model : String); end

        def self.build_from(body : String)
          from_json(body)
        end
      end

      def initialize(@model : String = EMBEDDING_MODEL); end

      def generate(query)
        result = client.post EMBEDDING_ENDPOINT, body: Request.build(input: query, model: @model)
        if result.status == HTTP::Status::OK
          Response.build_from(result.body)
        else
          raise "Could not generate embeddings"
        end
      end

      private def client
        @client ||= HTTP::Client.new(host: EMBEDDING_MODEL_HOST, port: EMBEDDING_MODEL_PORT)
      end
    end
  end
end
