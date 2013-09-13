require 'structle'

module Ns
  class Foo < Structle::Struct
    id 0x01
    field :foo, Structle::Uint32
    field :bar, Structle::Int16
    field :baz, Structle::Bytes, size: 10
  end

  class Bar < Structle::Struct
    id 0x02
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
    id 0x03
    field :foo, BazEnum
  end

  module Ns2
    class BazEnum < Structle::Enum
      field Structle::Uint8
      value :FOOBAR
      value :BARBAR
      value :BAZBAR
    end

    class Baz < Structle::Struct
      id 0x04
      field :foo, BazEnum
    end
  end
end
