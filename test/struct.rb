require 'structle'

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
end
