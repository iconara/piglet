module Piglet
  module Schema
    class Tuple
      attr_reader :field_names
      
      def initialize(field_names, type_map)
        @field_names = [ ]
        @field_names = field_names.dup if field_names
        @type_map = { }
        @type_map = type_map.dup if type_map
      end
      
      # Returns a new Tuple with a schema described by the specified array.
      #
      # The array will be interpreted as follows: each element defines a field,
      # and a field can have an optional type. To define a typeless field simply
      # use a symbol, to define a typed field use an array with two values: the
      # first is the name and the second is the type.
      #
      # The type of a field can be one of the following:
      # * <code>:int</code>
      # * <code>:long</code>
      # * <code>:float</code>
      # * <code>:double</code>
      # * <code>:chararray</code>
      # * <code>:bytearray</code>
      # * <code>:tuple</code> or Piglet::Schema::Tuple
      # * <code>:bag</code> or Piglet::Schema::Bag
      #
      # If a type is not given it defaults to <code>:bytearray</code>. To define
      # a tuple field either pass a Piglet::Schema::Tuple object as the type, or
      # use <code>:tuple</code> and a thrid element, which is the schema of the
      # tuple, e.g. <code>[[:a, :tuple, [:b, :c]]]</code>.
      #
      # Maps are currently not supported.
      #
      # Examples (Piglet schema description to the left with the Pig Latin
      # schema definition to the right):
      #
      #   [:a, :b, :c]                     # => (a:bytearray, b:bytearray, c:bytearray)
      #   [[:a, :chararray], [:b, :float]] # => (a:chararray, b:float)
      #   [[:a, Tuple.parse(:b, :c)]]      # => (a:tuple (b:bytearray, c:bytearray))
      #   [[:a, :bag, [:b, :c]]]           # => (a:bag {x:tuple (b:bytearray, c:bytearray)})
      def self.parse(description)
        field_names = [ ]
        type_map = { }
        description.map do |component|
          case component
          when Enumerable
            head = component.first
            tail = component[1..-1]
            case tail.first
            when :tuple
              type_map[head] = parse(*tail[1..-1])
            when :bag
              type_map[head] = Bag.new(parse(*tail[1..-1]))
            else
              type_map[head] = tail.first
            end
            field_names << head
          else
            type_map[component] = :bytearray
            field_names << component
          end
        end
        Tuple.new(field_names, type_map)
      end
      
      def union(*tuples)
        field_names = @field_names.dup
        type_map = @type_map.dup
        tuples.flatten.each do |tuple|
          tuple.field_names.each do |f|
            field_names << f
            type_map[f] = tuple.field_type(f)
          end
        end
        Tuple.new(field_names, type_map)
      end
      
      def field_type(field_name)
        @type_map[field_name]
      end
    end
  end
end