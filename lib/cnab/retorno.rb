module Cnab
  class Retorno
    include PrettyInspect

    def initialize(args = {})
      @header_arquivo = args[:header_arquivo]
      @header_lote = args[:header_lote]
      @trailer_arquivo = args[:trailer_arquivo]
      @trailer_lote = args[:trailer_lote]
      @segmento_y_50 = args[:segmento_y_50]
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