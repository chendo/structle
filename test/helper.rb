require 'structle'
require 'minitest/autorun'

module Ns
  class Foo < Structle::Struct
    field :foo, Structle::Uint32
    field :bar, Structle::Int16
    field :baz, Structle::Bytes, size: 10
  end

  class Bar < Structle::Struct
    field :foo, Foo
    field :bar, Structle::Uint64
    field :baz, Structle::Bytes, size: 32
  end

  class BazEnum < Structle::Enum
    field Structle::Uint8
    value :FOO
    value :BAR
    value :BAZ
  end

  class Baz < Structle::Struct
    field :foo, BazEnum
  end

  class Bitfield < Structle::Bitfield
    type Structle::Uint16
    field :uint12, Structle::Uint16, bits: 12
    field :bool, Structle::Bool, bits: 1
    field :bool2, Structle::Bool, bits: 1
    field :uint2, Structle::Uint8, bits: 2
  end

  module Ns2
    class BazEnum < Structle::Enum
      namespaced false
      field Structle::Uint8
      value :FOOBAR
      value :BARBAR
      value :BAZBAR
    end
    p BazEnum.namespaced
    class Baz < Structle::Struct
      field :foo, BazEnum
    end

    class Empty < Structle::Struct
    end
  end
end
