# protocol

* [Source](https://github.com/shanna/protocol)
* [Todo](https://github.com/shanna/protocol/issues?labels=enhancement&page=1&state=open)
* [MIT License](https://github.com/shanna/protocol/blob/master/LICENSE)

## Description

Protocol generates little-endian C compartible structs suitable as a simple,
fast wire protocol.

## Why little-endian?

Because x86, x86-64 and bi-endian ARM M3 etc. can all read these structures
into memory with minimal effort.

## Protocol DSL

```ruby
package :my do
  package :namespace do
    enum :enum_example, {this: 1, that: 2, other: 99}

    struct :struct_example do
      enum_example :field_enum
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

## Generation

## CLI

```ruby
protocol c99 test/test.protocol
```

## Ruby

```ruby
# From file or string.
package = Protocol::Package.load 'test/test.protocol'
package = Protocol::Package.new.parse File.read('test/test.protocol')

# Apply a template to the package tree.
puts Protocol::Language::C99.new.apply(package)
```

## License

MIT

