# structle

* [Source](https://github.com/shanna/structle)
* [Todo](https://github.com/shanna/structle/issues?labels=enhancement&page=1&state=open)
* [MIT License](https://github.com/shanna/structle/blob/master/LICENSE)

## Description

Structle defines and generates little-endian C compatible structs suitable as
a simple, fast wire protocol.

## Why little-endian?

Because x86, x86-64 and bi-endian ARM M3 etc. can all read these structures
into memory with minimal effort.

### Ruby

```ruby
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

#define NS_TYPES \
  X(NS_FOO, ns_foo) \
  X(NS_BAR, ns_bar)

#define X(constant, name) constant,
typedef enum ns_types_t {
  NS_TYPES
} ns_types_t;
#undef X

#pragma pack(push, 1)
typedef struct ns_foo_t {
  uint32_t foo;
  int16_t  bar;
  uint8_t  baz[10];
} ns_foo_t;
#pragma pack(pop)

#pragma pack(push, 1)
typedef struct ns_bar_t {
  ns_foo_t foo;
  uint64_t bar;
  uint8_t  baz[32];
} ns_bar_t;
#pragma pack(pop)

#ifdef __cplusplus
  }
#endif
```

### CLI

```bash
structle c99 test/struct.rb > test.h
```

### Ruby

```ruby
# Load your ruby structs.
load 'my/structs.rb'

puts 'Generating structs:', Structle.structs
puts Structle::Language::C99.new.generate
```

## License

MIT

