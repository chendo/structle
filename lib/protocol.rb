require 'stringio'

module Protocol
  module Serializer; end

  Field = ::Struct.new(:name, :type, :pack, :size) do
    include Serializer

    def protocol_load io
      type.kind_of?(Serializer) ? type.protocol_load(io) : io.read(size).to_s.unpack(pack).first
    end

    def protocol_dump io, value
      type.kind_of?(Serializer) ? type.protocol_dump(io) : io.write([value].pack(pack))
    end
  end

  class Struct
    include Serializer

    def initialize options = {}
      options.each{|k, v| public_send(:"#{k}=", v)}
    end

    def protocol_dump io
      type.protocol_dump io, self
    end

    class << self
      attr_accessor :fields

      def inherited klass
        super
        klass.fields = []
      end

      def field name, type, pack, size
        fields.push field = Field.new(name, type, pack, size)
        define_singleton_method(name, lambda{ field })
        attr_accessor name
      end

      def protocol_dump io, value
        fields.inject(0) do |bytes, field|
          bytes + field.dump(io, value.public_send(field.name))
        end
      end

      def protocol_load io
        fields.inject(new) do |struct, field|
          struct.public_send("#{field.name}=", field.load(io))
          struct
        end
      end
    end
  end
end
