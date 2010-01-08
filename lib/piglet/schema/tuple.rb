module Piglet
  module Schema
    class Tuple
      attr_reader :field_names
      
      def initialize(description)
        @field_names = [ ]
        @type_map = { }
        parse(description)
      end
      
      def field_type(field_name)
        @type_map[field_name]
      end
    
    private
    
      def parse(description)
        description.map do |component|
          case component
          when Enumerable
            @field_names << component.first
            @type_map[component.first] = component.last
          else
            @field_names << component
            @type_map[component] = :bytearray
          end
        end
      end
    end
  end
end