module Piglet
  module Relation
    class Stream # :nodoc:
      include Relation
      
      def initialize(source, args, options=nil)
        options ||= {}
        @sources = [source]
        args.each do |arg|
          @sources << arg if arg.is_a?(Relation)
        end
        @command_reference = (args - @sources).first
        @command = options[:command]
      end
      
      def to_s
        source_str = @sources.map { |s| s.alias }.join(', ')
        str = "STREAM #{source_str} THROUGH"
        if @command_reference
          str << " #{@command_reference}" 
        else
          str << " `#{@command}`"
        end
        str
      end
    end
  end
end