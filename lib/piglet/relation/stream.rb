# encoding: utf-8

module Piglet
  module Relation
    class Stream # :nodoc:
      include Relation
      
      def initialize(source, args, options=nil)
        options ||= {}
        @sources = [source]
        args.each do |arg|
          @sources << arg if arg.is_a?(Relation) || arg.is_a?(Array)
        end
        @command_reference = (args - @sources).first
        @sources = @sources.flatten
        @command = options[:command]
        @schema = options[:schema]
      end
      
      def schema
        if @schema
          Piglet::Schema::Tuple.parse(@schema)
        else
          nil
        end
      end
      
      def to_s
        source_str = @sources.map { |s| s.alias }.join(', ')
        str = "STREAM #{source_str} THROUGH"
        if @command_reference
          str << " #{@command_reference}" 
        else
          str << " `#{@command}`"
        end
        if @schema
          str << " AS #{schema}"
        end
        str
      end
    end
  end
end