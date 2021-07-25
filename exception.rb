module KinopoiskApi
  class Exception < StandardError
    attr_reader :operation_type

    def initialize(msg: nil, operation_type: nil)
      @operation_type = operation_type

      super(msg)
    end
  end
end
