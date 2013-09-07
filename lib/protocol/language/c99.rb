require 'protocol/language'

class Protocol::Language::C99 < Protocol::Language
  module Conventions
    include Protocol::Language::Conventions
    def type *name; snake_case *name, 't' end
  end

  language    'c99'
  description 'C99 little-endian.'
  template    File.join(File.dirname(__FILE__), 'c99.template')
end
