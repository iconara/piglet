module Piglet
  module Udf
    class Define
      include Piglet::Inout::StorageTypes
      
      def initialize(ali4s, options=nil)
        options ||= {}
        @alias = ali4s
        @command = options[:command]
        @function = options[:function]
        @input = options[:input]
        @output = options[:output]
        @ship = options[:ship]
        @cache = options[:cache]
      end
      
      def to_s
        if @command
          str = "DEFINE #{@alias} `#{@command}`"
          str << io_to_s(:input, @input) if @input
          str << io_to_s(:output, @output) if @output
          str << paths_to_s(:ship, @ship) if @ship
          str << paths_to_s(:cache, @cache) if @cache
          str
        else
          "DEFINE #{@alias} #{@function}"
        end
      end
      
    private
    
      def paths_to_s(kind, paths)
        unless Enumerable === paths
          paths = [paths]
        end
        path_str = paths.map { |p| "'#{p}'" }.join(', ')
        " #{kind.to_s.upcase}(#{path_str})"
      end
            
      def io_to_s(method, description)
        case description
        when Symbol, String
          if method == :input
            io_to_s(method, [{:from => description}])
          else
            io_to_s(method, [{:to => description}])
          end
        when Hash
          io_to_s(method, [description])
        when Enumerable
          str = " #{method.to_s.upcase}("
          description_strs = description.map do |desc|
            stream = (method == :input ? desc[:from] : desc[:to])
            stream = "'#{stream}'" unless Symbol === stream
            if desc[:using]
              "#{stream} USING #{resolve_load_store_function(desc[:using])}"
            else
              stream.to_s
            end
          end
          str << description_strs.join(', ')
          str << ')'
          str
        end
      end
    end
  end
end