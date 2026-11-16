module SemanticNotesSearcher
  module Models
    annotation Table; end
    annotation Column; end

    module Queryable
      module Types
        alias Any = DB::Any
      end

      macro included
        {% if table = @type.annotation(Table) %}
          def self.table_name
            {{ table[:name] }}
          end
      {% end %}
      end

      def insert_statement : Tuple(String, Array(Types::Any))
        columns = db_columns

        {
          "INSERT INTO #{self.class.table_name} " \
          "(#{columns.join(", ")}) " \
          "VALUES (#{columns.map { |_| "?" }.join(", ")})",

          db_parameters(columns),
        }
      end

      def update_statement : Tuple(String, Array(Types::Any))
        columns = db_columns.reject(&.==("id"))

        {
          "UPDATE #{self.class.table_name} " \
          "SET #{columns.map { |column| "#{column} = ?" }.join(", ")} " \
          "WHERE id = ?",

          db_parameters(columns) << id,
        }
      end

      private def db_columns : Array(String)
        columns = [] of String

        {% for ivar in @type.instance_vars %}
          {% if column = ivar.annotation(Column) %}
            columns << {{ column[:name] || ivar.name.stringify }}
          {% end %}
        {% end %}

        columns
      end

      private def db_parameters(column_names : Array(String))
        values = Hash(String, Types::Any).new
        {% for ivar in @type.instance_vars %}
          {% if column = ivar.annotation(Column) %}
            values[ {{ column[:name] }}] = {{ ivar }}
          {% end %}
        {% end %}
        column_names.map { |column| values[column] }
      end
    end
  end
end
