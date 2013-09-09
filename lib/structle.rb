require 'stringio'

module Structle
  class Struct
    class Field
      attr_accessor :name, :pack, :size, :type

      def initialize name, pack, size, options = {}
        @name, @pack, @size, @type = name, pack, size, options.values_at(:type, :class).first
      end

      def structle_load io
        type.respond_to?(:structle_load) ? type.structle_load(io) : io.read(size).to_s.unpack(pack).first
      end

      def structle_dump io, value
        type.respond_to?(:structle_dump) ? type.structle_dump(io, value) : io.write([value].pack(pack))
      end
    end

    def initialize options = {}
      options.each{|k, v| public_send("#{k}=", v)}
    end

    def structle_dump io
      self.class.structle_dump io, self
    end

    class << self
      attr_accessor :fields

      def inherited klass
        super
        klass.fields = []
      end

      def field name, pack, size, options = {}
        fields.push field = Field.new(name, pack, size, options)
        define_singleton_method(name, lambda{ field })
        attr_accessor name
      end

      def structle_dump io, value
        fields.inject(0){|b, f| b + f.structle_dump(io, value.public_send(f.name))}
      end

      def structle_load io
        fields.inject(new){|s, f| s.public_send("#{f.name}=", f.structle_load(io)); s}
      end
    end
  end
end
