module Cnab
  class Lote
    include PrettyInspect

    def initialize(args = {})
      @header_lote = args[:header_lote]
      @trailer_lote = args[:trailer_lote]
      @detalhes = args[:detalhes] || []
    end

    def method_missing(method_name)
      return instance_variable_get("@#{method_name}") if instance_variable_defined?("@#{method_name}")
      super
    end

    def respond_to_missing?(method_name, include_private = false)
      return true if instance_variable_defined?("@#{method_name}")
      super
    end
  end
end
