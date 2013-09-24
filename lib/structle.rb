require 'stringio'

module Structle
  class << self
    def namespaces
      [@structs, @enums].flatten.map(&:namespace).uniq
    end

    def structs namespace = nil
      @structs ||= []
      namespace ? @structs.select{|s| s.namespace == namespace} : @structs
    end

    def enums namespace = nil
      @enums ||= []
      namespace ? @enums.select{|s| s.namespace == namespace} : @enums
    end
  end

  class Type
    class << self
      attr_writer :size
      attr_accessor :format

      def define size, format, options = {}
        Class.new(self){ @size, @format = size, format }
      end

      def pack io, value
        io.write value.nil? ? "\x00" * size : [value].pack(format)
      rescue TypeError => error
        raise %q{pack '%s' into format '%s' %s} % [value.inspect, format, error.message]
      end

      def unpack io
        io.read(size).unpack(format).first
      end

      def name
        super || superclass.name
      end

      def size
        @size.to_i
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
    self.size, self.format = 1, 'C'

    def self.pack io, value
      super(io, value.kind_of?(TrueClass) ? 1 : 0)
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

  class String < Type
    def self.format
      'A%d' % size.to_i
    end
  end

  # TODO: Composite Union and Bitfield types.

  # By default Uint16 type is used.
  #
  # Guessing the size based on values is probably going to fall over on some
  # compilers. Use field with a Structle::Type numeric type.
  #--
  # TODO: Type checking? Automatic size guessing?
  class Enum < Type
    self.size, self.format = 2, 'S<'

    class << self
      attr_accessor :values, :type, :namespaced

      def [] key
        values[key]
      end

      def inherited klass
        Structle.enums << klass if klass.superclass == Enum
        klass.values     = values || {}
        klass.type       = type || Uint16
        klass.namespaced = namespaced
      end

      def field type
        self.type   = Class.new(type)
        self.format = type.format
        self.size   = type.size
      end

      def namespace
        name.split('::').map(&:to_sym)[0...-1]
      end

      def namespaced value = nil
        @namespaced = true if @namespaced.nil?
        @namespaced = !!value unless value.nil?
        @namespaced
      end

      def namespaced?
        namespaced
      end

      def value name, value = nil, options = {}
        last         = values.values.reverse.reject(&:nil?).first
        values[name] = (value ||= last.nil? ? 0 : last.to_i + 1)
        const_set name, value
      end
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

      def complete?
        !fields.empty?
      end

      def size
        fields.values.map(&:size).reduce(:+).to_i
      end

      def format
        fields.values.map(&:format).join
      end

      def field name, type, options = {}
        fields[name] = type.define(options.fetch(:size, type.size), options.fetch(:format, type.format), options)
        attr_accessor name
      end

      def namespace
        name.split('::').map(&:to_sym)[0...-1]
      end

      def pack io, value
        fields.inject(0) do |b, (n, f)|
          begin
            b + f.pack(io, value.public_send(n))
          rescue => error
            raise %q{Field '%s' %s} % [n, error.message]
          end
        end
      end

      def unpack io
        new fields.each_with_object({}){|(n, f), h| h[n] = f.unpack(io)}
      end
    end
  end
end
