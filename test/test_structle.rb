require_relative 'helper'
require 'minitest/autorun'

describe 'Structle' do
  before do
    @it = Structle
  end

  it 'should have namespacing' do
    assert_equal :Ns,     @it.namespaces.first.first
    assert_equal Ns::Foo, @it.structs.first
    assert_equal Ns::Foo, @it.structs([:Ns]).first
    assert_equal nil,     @it.structs([]).first

    assert_equal Ns::BazEnum, @it.enums.first
    assert_equal Ns::BazEnum, @it.enums([:Ns]).first
    assert_equal nil,         @it.enums([]).first

    assert_equal Ns::Ns2::BazEnum, @it.enums([:Ns, :Ns2]).first
  end

  describe 'Enum' do
    before do
      @it = Ns::BazEnum
    end

    it 'should have const' do
      assert value = @it.const_get(:FOO)
      assert_equal 1, @it.const_get(:BAR)
    end

    it 'should have size and format for type' do
      assert_equal 'C', @it.format
      assert_equal 1,   @it.size
    end
  end

  describe 'Struct' do
    before do
      foo = Ns::Foo.new(foo: 32, bar: 16, baz: 'woot')
      @it = Ns::Bar.new(foo: foo, bar: 64, baz: 'wozza')
    end

    it 'should pack' do
      io = StringIO.new
      assert @it.pack(io)
      io.rewind
      assert_equal(
        '200000001000776F6F740000000000004000000000000000776F7A7A61000000000000000000000000000000000000000000000000000000',
        io.read.bytes.map{|b| '%02X' % b}.join
      )
    end

    it 'should unpack' do
      assert_equal 64,        @it.bar
      assert_equal 'wozza',   @it.baz.chomp
      assert_kind_of Ns::Foo, @it.foo
      assert_equal 32,        @it.foo.foo
      assert_equal 16,        @it.foo.bar
      assert_equal 'woot',    @it.foo.baz
    end

    it 'should have namespace' do
      assert_equal :Ns, Ns::Foo.namespace.first
      assert_equal :Ns, Ns::Bar.fields[:foo].namespace.first
    end

    it 'should have name' do
      assert_equal 'Ns::Foo', Ns::Bar.fields[:foo].name
    end

    it 'should be kind of' do
      assert_kind_of Structle::Struct, @it
      assert_kind_of Structle::Struct, @it.foo
    end
  end

  describe 'Type' do
    it 'should pack & unpack Binary types with size field' do
      klass = Structle::Binary.define(8, 'C*')
      value = klass.new("foo", 3)

      assert_equal 10, klass.size

      io = StringIO.new
      klass.pack(io, value)

      io.rewind
      assert_equal 10, io.read.bytesize

      io.rewind
      obj = klass.unpack(io)
      assert_equal 'foo', obj.data
      assert_equal 3,     obj.size
    end
  end
end
