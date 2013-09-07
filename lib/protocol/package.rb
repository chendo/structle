module Protocol
  class Type
    attr_reader :package, :name

    def initialize package, name
      @package, @name = package, name
    end

    def namespace
      return unless @package
      [*@package.namespace, @package.name].compact
    end
  end

  class Branch < Type
    attr_reader :members

    def initialize package, name, &block
      super
      @members = []
      instance_eval &block if block_given?
    end

    protected
      def self.dsl_method name, klass
        define_method name, lambda{|*args, &block| @members << klass.new(self, *args, &block) }
      end
  end

  class User < Type
    attr_reader :klass

    def initialize package, name, klass
      super package, name
      @klass = klass
    end
  end

  class Enum < Branch
    def initialize package, name, members = {}
      super package, name
      @members = members
    end
  end

  class Bytes < Type
    attr_accessor :size

    def initialize package, name, size
      super package, name
      @size = size
    end
  end

  class Bool   < Type; end
  class Float  < Type; end
  class Double < Type; end
  class Uint8  < Type; end
  class Uint16 < Type; end
  class Uint32 < Type; end
  class Uint64 < Type; end
  class Int8   < Type; end
  class Int16  < Type; end
  class Int32  < Type; end
  class Int64  < Type; end

  class Struct < Branch
    dsl_method(:bool,   Bool)
    dsl_method(:bytes,  Bytes)
    dsl_method(:double, Double)
    dsl_method(:float,  Float)
    dsl_method(:int8,   Int8)
    dsl_method(:int16,  Int16)
    dsl_method(:int32,  Int32)
    dsl_method(:int64,  Int64)
    dsl_method(:uint8,  Uint8)
    dsl_method(:uint16, Uint16)
    dsl_method(:uint32, Uint32)
    dsl_method(:uint64, Uint64)

    def method_missing name, *args, &block
      klass = package.members.find{|m| !m.kind_of?(Package) and m.name == name}
      return @members << User.new(package, name, klass) if klass
      super
    end
  end

  class Package < Branch
    def types
      members.map{|m| m.kind_of?(Package) ? m.types : m}.flatten.compact
    end

    def structs
      types.select{|t| t.kind_of?(Struct)}
    end

    dsl_method(:enum,    Enum)
    dsl_method(:package, Package)
    dsl_method(:struct,  Struct)

    def self.load file
      new(nil, nil){ instance_eval File.read(file), file, 0 }
    end
  end
end
