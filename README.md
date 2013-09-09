# structle

* [Source](https://github.com/shanna/structle)
* [Todo](https://github.com/shanna/structle/issues?labels=enhancement&page=1&state=open)
* [MIT License](https://github.com/shanna/structle/blob/master/LICENSE)

## Description

Structle generates little-endian C compartible structs suitable as a simple,
fast wire protocol.

## Why little-endian?

Because x86, x86-64 and bi-endian ARM M3 etc. can all read these structures
into memory with minimal effort.

## Generation

### DSL

```ruby
package :my do
  package :namespace do
    struct :struct_example do
      bytes        :field_bytes, 32
      bool         :field_bool
      float        :field_float
      double       :field_double
      uint8        :field_uint8
      uint16       :field_uint16
      uint32       :field_uint32
      uint64       :field_uint64
      int8         :field_int8
      int16        :field_int16
      int32        :field_int32
      int64        :field_int64
    end
  end
end
```

### Languages.

* Ruby
* C99

### CLI

```bash
protocol c99 test/test.protocol > test.h
```

### Ruby

```ruby
# From file or string.
package = Structle::Def.load 'test/test.protocol'
package = Structle::Def.new.parse File.read('test/test.protocol')

# Apply a template to the package tree.
puts Structle::Language::C99.new.apply(package)
```

## License

MIT

