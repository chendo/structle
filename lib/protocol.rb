require 'protocol/package'
require 'protocol/template'

require 'protocol/language'
require 'protocol/language/c99'
#require 'protocol/language/c99-portable'
#require 'protocol/language/ruby'
#require 'protocol/language/ruby-portable'
#require 'protocol/language/objc'
#require 'protocol/language/objc-portable'


# Protocol
#
# Protocol generates little-endian C compartible structs suitable as a simple,
# fast wire protocol.
#
# Why little-endian? Because x86, x86-64 and bi-endian ARM M3 etc. can all read
# these structures into memory with minimal effort.
module Protocol; end
