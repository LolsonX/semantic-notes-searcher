module SemanticNotesSearcher
  module DI
    class Container
      abstract class Entry; end

      class ResolutionError < Exception; end

      class Holder(T) < Entry
        getter value : T

        def initialize(@value : T); end
      end

      @tokens = {} of String => Entry

      def token(key : String, type : T.class) : T forall T
        entry = @tokens[key]? || raise ResolutionError.new("DI: no value registered for token #{key.inspect}")
        entry.as(Holder(T)).value
      end

      def register(token : String, value : T) : Nil forall T
        @tokens[token] = Holder(T).new(value)
      end

      def get(type : T.class) : String forall T
        "ok"
      end
    end
  end
end
