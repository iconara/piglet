module Piglet
  module Inout
    class Load # :nodoc:
      include Piglet::Relation::Relation
      include StorageTypes
    
      def initialize(path, options={})
        options ||= {}
        @path, @using, @schema = path, options[:using], options[:schema]
      end
    
      def to_s
        str  = "LOAD '#{@path}'"
        str << " USING #{resolve_load_store_function(@using)}" if @using
        str << " AS (#{schema_string})" if @schema
        str
      end
    
    private
        
      def schema_string
        @schema.map do |field|
          if field.is_a?(Enumerable)
            field.map { |f| f.to_s }.join(':')
          else
            field.to_s
          end
        end.join(', ')
      end
    end
  end
end