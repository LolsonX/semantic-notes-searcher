module SemanticNotesSearcher
  module Services
    abstract class Base
      abstract def call(*args, **kwargs) : Nil
    end
  end
end
