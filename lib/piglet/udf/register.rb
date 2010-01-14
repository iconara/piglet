module Piglet
  module Udf
    class Register
      def initialize(path)
        @path = path
      end
      
      def to_s
        "REGISTER #{@path}"
      end
    end
  end
end