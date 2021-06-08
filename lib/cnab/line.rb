module Cnab
  class Line
    include PrettyInspect

    def initialize(line, definition)
      raise Exceptions::LineNotParseable unless line.size == 242

      @line = line
      @definition = definition

      definition.instance_variable_get("@definition").each do |k, v|
        instance_variable_set("@#{k}", @line[Range.new *v.split('..').map{|m| m.to_i }])
      end
    end

    def method_missing(method_name)
      return instance_variable_get("@#{method_name}") if instance_variable_defined?("@#{method_name}")
      instance_variable_set("@#{method_name}", @line[@definition.send(method_name)].strip)
    end

    def respond_to_missing?(method_name, include_private = false)
      return true if definition.respond_to?(method_name)
      super
    end
  end
end