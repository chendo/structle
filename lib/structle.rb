require 'stringio'

module Structle
  def self.structs
    @structs ||= []
  end

  class Type
    class << self
      attr_accessor :size, :format

      def define size, format, options = {}
        Class.new(self){ @size, @format = size, format }
      end

      def pack io, value
        io.write [value].pack(format)
      end

      def unpack io
        io.read(size).unpack(format).first
      end

      def name
        super || superclass.name
      end
    end
  end

  class Uint8  < Type; self.size, self.format = 1, 'C'  end
  class Uint16 < Type; self.size, self.format = 2, 'S<' end
  class Uint32 < Type; self.size, self.format = 4, 'L<' end
  class Uint64 < Type; self.size, self.format = 8, 'Q<' end
  class Int8   < Type; self.size, self.format = 1, 'c'  end
  class Int16  < Type; self.size, self.format = 2, 's<' end
  class Int32  < Type; self.size, self.format = 4, 'l<' end
  class Int64  < Type; self.size, self.format = 8, 'q<' end
  class Float  < Type; self.size, self.format = 4, 'e'  end
  class Double < Type; self.size, self.format = 8, 'E'  end

  class Bool < Type
    self.format = 'C'

    def self.pack io, value
      super(value.kind_of?(TrueClass) ? 1 : 0)
    end

    def self.unpack io
      super(io) > 0 ? true : false
    end
  end

  class Bytes < Type
    def self.format
      'a%d' % size.to_i
    end
  end

  class Struct < Type
    def initialize options = {}
      options.each{|k, v| public_send("#{k}=", v)}
    end

    def pack io
      self.class.pack io, self
    end

    class << self
      attr_accessor :fields

      def inherited klass
        Structle.structs << klass if klass.superclass == Struct
        klass.fields = fields || {}  # Suck it 1.8
      end

      def size
        fields.map(&:size).reduce(:+)
      end

      def format
        fields.values.map(&:format).join
      end

      def field name, type, options = {}
        fields[name] = type.define(options.fetch(:size, type.size), options.fetch(:format, type.format), options)
        define_singleton_method(name, lambda{ fields[name] })
        attr_accessor name
      end

      def namespace
        name.split('::').map(&:to_sym)[0...-1]
      end

      def pack io, value
        fields.inject(0){|b, (n, f)| b + f.pack(io, value.public_send(n))}
      end

      def unpack io
        fields.inject(new){|s, (n, f)| s.public_send("#{n}=", f.unpack(io)); s}
      end
    end
  end
end

