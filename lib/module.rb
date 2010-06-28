class Module
  alias :_attr_reader :attr_reader
  def attr_reader(*attributes)
    attributes.each { |attribute|
      if attribute.id2name.end_with? '?'
        define_method(attribute) {
          instance_variable_get("@#{attribute[0...-1]}")
        }
      else
        _attr_reader(attribute)
      end
    }
  end
end
