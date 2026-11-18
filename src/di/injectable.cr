module SemanticNotesSearcher
  module DI
    annotation Injectable; end
    annotation Inject; end

    macro finished
      {% for type in Object.all_subclasses %}
        {% if injectable_annotation = type.annotation(::SemanticNotesSearcher::DI::Injectable) %}
          {% constructor = type.methods.find(&.name.stringify.==("initialize")) %}
          {% regular = constructor.args.reject(&.annotation(::SemanticNotesSearcher::DI::Inject)) %}
          {% call_args = [] of String %}
          {% for arg in constructor.args %}
            {% if inject_annotation = arg.annotation(::SemanticNotesSearcher::DI::Inject) %}
              {% call_args << "#{arg.name.id}: container.token(#{inject_annotation[0]}, #{arg.restriction})" %}
            {% elsif arg.default_value.is_a?(Nop) %}
              {% if arg.restriction.is_a?(Nop) %}
                {% raise "DI: #{type}#initialize parameter `#{arg.name}` needs a type restriction to be injected." %}
              {% end %}
              {% call_args << "#{arg.name.id}: container.get(#{arg.restriction})" %}
            {% end %}
          {% end %}

          class ::{{ type }}
            def self.__di_build(container : ::SemanticNotesSearcher::DI::Container) : self
              new({{ call_args.join(", ").id }})
            end
          end
        {% end %}
      {% end %}
    end
  end
end
