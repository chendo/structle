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

### Languages

#### Generated portable Ruby

```ruby
require 'structle'

module My
module Namespace
class SubStruct < Structle::Struct
  field :field_test, "C", 1
  field :field_bytes, "a6", 6
end

class StructExample < Structle::Struct
  field :field_sub_struct, "Ca6", 7, type: SubStruct
  field :field_bytes, "a32", 32
  field :field_bool, "C", 1
  field :field_float, "e", 4
  field :field_double, "E", 8
  field :field_uint8, "C", 1
  field :field_uint16, "S<", 2
  field :field_uint32, "L<", 4
  field :field_uint64, "Q<", 8
  field :field_int8, "c", 1
  field :field_int16, "s<", 2
  field :field_int32, "l<", 4
  field :field_int64, "q<", 8
end

end # Namespace
end # My
```

#### Generated little-endian C99

```C
#pragma once

#ifdef __cplusplus
  extern "C" {
#endif

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#define MY_NAMESPACE_TYPES \
  X(MY_NAMESPACE_SUB_STRUCT, my_namespace_sub_struct) \
  X(MY_NAMESPACE_STRUCT_EXAMPLE, my_namespace_struct_example) 

#define X(constant, name) constant,
typedef enum my_namespace_types_t {
  MY_NAMESPACE_TYPES
} my_namespace_types_t;
#undef X

#pragma pack(push, 1)
typedef struct my_namespace_sub_struct_t {
  uint8_t  field_test;
  uint8_t  field_bytes[6];
} my_namespace_sub_struct_t;
#pragma pack(pop)

#pragma pack(push, 1)
typedef struct my_namespace_struct_example_t {
  my_namespace_sub_struct_t field_sub_struct;
  uint8_t  field_bytes[32];
  bool     field_bool;
  float    field_float;
  double   field_double;
  uint8_t  field_uint8;
  uint16_t field_uint16;
  uint32_t field_uint32;
  uint64_t field_uint64;
  int8_t   field_int8;
  int16_t  field_int16;
  int32_t  field_int32;
  int64_t  field_int64;
} my_namespace_struct_example_t;
#pragma pack(pop)

#ifdef __cplusplus
  }
#endif
```

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

