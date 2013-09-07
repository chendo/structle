# protocol

[source](https://bitbucket.org/shanna/protocol)

## Description

Protocol generates little-endian C compartible structs suitable as a simple,
fast wire protocol.

## Why little-endian?

Because x86, x86-64 and bi-endian ARM M3 etc. can all read these structures
into memory with minimal effort.

## License

MIT

