module Structle
  class Def
    attr_reader :packages, :name, :members

    def namespace
      packages.map(&:name).compact
    end

    def initialize packages, name, &block
      @packages, @name, @members = [packages].flatten.compact, name, []
      instance_eval &block if block_given?
    end

    def self.parse source, filename, lineno
      root = Package.new(nil, nil)
      root.instance_eval(source, filename, lineno)
      root
    end

    class Field < Def
      attr_reader :type, :pack, :size

      def initialize packages, name, type, pack, size
        super packages, name
        @type, @pack, @size = type, pack, size
      end
    end

    class Struct < Def
      def bool   name;       @members << Field.new(packages, name, :bool,   'C',          1   ) end
      def bytes  name, size; @members << Field.new(packages, name, :bytes,  'a%s' % size, size) end
      def float  name;       @members << Field.new(packages, name, :float,  'e',          4   ) end
      def double name;       @members << Field.new(packages, name, :double, 'E',          8   ) end
      def uint8  name;       @members << Field.new(packages, name, :uint8,  'C',          1   ) end
      def uint16 name;       @members << Field.new(packages, name, :uint16, 'S<',         2   ) end
      def uint32 name;       @members << Field.new(packages, name, :uint32, 'L<',         4   ) end
      def uint64 name;       @members << Field.new(packages, name, :uint64, 'Q<',         8   ) end
      def int8   name;       @members << Field.new(packages, name, :int8,   'c',          1   ) end
      def int16  name;       @members << Field.new(packages, name, :int16,  's<',         2   ) end
      def int32  name;       @members << Field.new(packages, name, :int32,  'l<',         4   ) end
      def int64  name;       @members << Field.new(packages, name, :int64,  'q<',         8   ) end
      def string name, size; @members << Field.new(packages, name, :string, 'A%s' % size, size) end

      def method_missing type_name, name, *args, &block
        if klass = packages.last.members.find{|m| !m.kind_of?(Package) and m.name == type_name}
          pack = klass.members.inject(''){|m, f| m + f.pack}
          size = klass.members.inject(0){|m, f| m + f.size}
          return @members << Field.new(klass.packages, name, klass, pack, size)
        end
        super
      end
    end

    class Package < Def
      def struct  name, &block; @members << Struct.new( [packages, self], name, &block) end
      def package name, &block; @members << Package.new([packages, self], name, &block) end

      def types
        members.map{|m| m.respond_to?(:types) ? m.types : m}.flatten.compact
      end

      def structs
        types.select{|t| t.kind_of?(Struct)}
      end
    end
  end
end
