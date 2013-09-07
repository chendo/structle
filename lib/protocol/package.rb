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

    def size
      self.class.size
    end

    def self.size size = nil
      @size = size if size
      @size
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

    def size
      klass.size
    end

    def initialize package, name, klass
      super package, name
      @klass = klass
    end
  end

  class Enum < Branch
    size 1

    def initialize package, name, members = {}
      super package, name
      @members = members
    end
  end

  class Bytes < Type
    attr_reader :size

    def initialize package, name, size
      super package, name
      @size = size
    end
  end

  class Bool   < Type; size 1; end
  class Float  < Type; size 4; end
  class Double < Type; size 8; end
  class Uint8  < Type; size 1; end
  class Uint16 < Type; size 2; end
  class Uint32 < Type; size 4; end
  class Uint64 < Type; size 8; end
  class Int8   < Type; size 1; end
  class Int16  < Type; size 2; end
  class Int32  < Type; size 4; end
  class Int64  < Type; size 8; end

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

    def size
      members.inject(0){|sum, m| sum + m.size}
    end

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
