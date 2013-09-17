require 'structle'

module Ns
  class Foo < Structle::Struct
    id 1
    field :foo, Structle::Uint32
    field :bar, Structle::Int16
    field :baz, Structle::Bytes, size: 10
  end

  class Bar < Structle::Struct
    id 2
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
    id 3
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
      id 4
      field :foo, BazEnum
    end

    class Empty < Structle::Struct
      id 5
    end
  end
end
