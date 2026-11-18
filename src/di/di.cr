require "./injectable"
require "./container"

module SemanticNotesSearcher
  module DI
    class_getter container : Container = Container.new
  end
end
