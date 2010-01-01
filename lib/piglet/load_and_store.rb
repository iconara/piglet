module Piglet  
  module LoadAndStore # :nodoc:
    LOAD_STORE_FUNCTIONS = {
      :binary_serializer => 'BinarySerializer',
      :binary_deserializer => 'BinaryDeserializer',
      :bin_storage => 'BinStorage',
      :pig_storage => 'PigStorage',
      :pig_dump => 'PigDump',
      :text_loader => 'TextLoader'
    }
    
    def resolve_load_store_function(name)
      LOAD_STORE_FUNCTIONS[name] || name.to_s
    end
  end
end