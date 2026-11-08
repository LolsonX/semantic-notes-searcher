require "./spec_helper"

describe SemanticNotesSearcher do
  describe SemanticNotesSearcher::Indexer do
    indexer = SemanticNotesSearcher::Indexer.new

    describe "given directory with notes exists" do
      context "when search for inside directory pointed by user" do
        directory = "#{FIXTURES_PATH}/notes/"
        indexer.index(directory)

        it "then indexes markdown in given directory" do
          indexer.indexed?("example_markdown").should be_truthy
        end

        it "then indexes recursively" do
          indexer.indexed?("nested_example/nested_directory_markdown").should be_truthy
        end
      end
    end
  end
end
