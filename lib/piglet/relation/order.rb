# encoding: utf-8

module Piglet
  module Relation
    class Order # :nodoc:
      include Relation
    
      def initialize(relation, interpreter, fields, options)
        options ||= {}
        @interpreter = interpreter
        @sources, @parallel = [relation], options[:parallel]
        @fields = fields.is_a?(Enumerable) ? fields : [fields]
      end
    
      def to_s
        target = @sources.first.respond_to?(:field_alias) ? @sources.first.field_alias : @sources.first.alias
        "ORDER #{target} BY #{field_strings}"
      end
    
    private
  
      def field_strings
        @fields.map { |f| field_string(f) }.join(', ')
      end
    
      def field_string(f)
        if f.is_a?(Enumerable)
          "#{f[0]} #{f[1].to_s.upcase}"
        else
          f.to_s
        end
      end
    end
  end
end