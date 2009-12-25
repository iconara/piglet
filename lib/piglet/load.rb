module Piglet
  class Load
    def initialize(path)
      @path = path
      @method = nil
      @fields = nil
    end
    
    def using(method)
      @method = method
      self
    end
    
    def as(*fields)
      @fields = fields
      self
    end
    
    def to_pig_latin
      str = "LOAD '#{@path}'"
      str << " USING #{method_name}" if @method
      str << " AS (#{field_list})" if @fields
      str
    end
  
  private
  
    def method_name
      case @method
      when :pig_latin
        'PigLatin'
      else
        @method
      end
    end
    
    def field_list
      @fields.map do |field|
        if field.is_a?(Enumerable)
          field.map { |f| f.to_s }.join(':')
        else
          field.to_s
        end
      end.join(', ')
    end
    
  end
end