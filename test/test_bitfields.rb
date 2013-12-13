require_relative 'helper'

describe 'Bitfields' do
  let(:uint12) { 127 }
  let(:bool) { true }
  let(:bool2) { false }
  let(:uint2) { 1 }
  let(:struct) { Ns::Bitfield.new(:uint12 => uint12, :bool => bool, :bool2 => bool2, :uint2 => uint2) }
  let(:io) { StringIO.new }

  describe 'packing' do
    let(:output) do
      struct.pack(io)
      io.rewind
      io.read
    end

    it 'has the correct length' do
      assert_equal 2, output.length
    end

    it 'has the correct data' do
      assert_equal "\x7f\x50", output
    end

    it 'can be unpacked' do
      unpacked_struct = Ns::Bitfield.unpack(StringIO.new(output))
      assert_equal uint12, unpacked_struct.uint12
      assert_equal bool, unpacked_struct.bool
      assert_equal bool2, unpacked_struct.bool2
      assert_equal uint2, unpacked_struct.uint2
    end
  end

  describe 'unpacking' do
    let(:packed) { "\x7f\x50" }
    it 'unpacks correctly' do
      unpacked = Ns::Bitfield.unpack(StringIO.new(packed))
      assert_equal Ns::Bitfield, unpacked.class
      assert_equal 127, unpacked.uint12
      assert_equal true, unpacked.bool
      assert_equal false, unpacked.bool2
      assert_equal 1, unpacked.uint2
    end
  end

  describe '#uint_at_range' do
    let(:subject) { Structle::Bitfield }
    let(:data) { 0b1100110011101101 }
    it 'returns the integer on the left bound' do
      assert_equal 0b101, subject.uint_at_range(data, Structle::Uint16, 0, 3)
    end

    it 'returns the integer on the right bound' do
      assert_equal 0b011101, subject.uint_at_range(data, Structle::Uint16, 3, 6)
    end
  end

  describe 'inside a struct' do
    let(:struct) do
      Ns::Qux.new(foo: 12345, bar: 128).tap do |instance|
        instance.bits = Ns::Bitfield.new
        instance.bits.uint12 = 127
        instance.bits.bool = true
        instance.bits.bool2 = false
        instance.bits.uint2 = 1
      end
    end

    let(:output) do
      struct.pack(io)
      io.rewind
      io.read.force_encoding(Encoding::BINARY)
    end

    it 'packs into 6 bytes' do
      assert_equal 6, output.length
    end

    it 'can be unpacked' do
      unpacked = Ns::Qux.unpack(StringIO.new(output))
      assert_equal 12345, unpacked.foo
      assert_equal 128, unpacked.bar
      assert_equal 127, unpacked.bits.uint12
      assert_equal true, unpacked.bits.bool
      assert_equal false, unpacked.bits.bool2
      assert_equal 1, unpacked.bits.uint2
    end
  end
end
