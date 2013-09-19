require_relative 'helper'
require 'structle/language/c99'
require 'minitest/autorun'

describe 'Structle::Language::C99' do
  it 'should generate' do
    c99 = Structle::Language::C99.new.generate
    assert_match /typedef enum ns_baz_enum_t/, c99, 'enums generated'
    assert_match /typedef struct ns_foo_t/, c99, 'structs generated'
    assert_match /X\(NS_FOO, ns_foo, 3\)/, c99, 'struct types x macro'

    # Binary
    expect =<<-EOS
    typedef struct ns_baz_t {
      uint8_t  foo;
      struct {
        uint8_t data[8];
        uint8_t size;
      } bar;
    } ns_baz_t;
    EOS

    expect.gsub!(%r{^\s{4}}m, '')
    assert_match expect, c99
  end
end
