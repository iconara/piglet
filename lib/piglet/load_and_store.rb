module Piglet
  module LoadAndStore # :nodoc:
    def resolve_load_store_function(name)
      case name
      when :pig_storage
        'PigStorage'
      else
        name
      end
    end
  end
end