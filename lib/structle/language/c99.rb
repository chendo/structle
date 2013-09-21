require 'structle/language'

class Structle::Language::C99 < Structle::Language
  module Conventions
    include Structle::Language::Conventions
    def type *name; snake_case *name, 't' end
  end

  language    'c99'
  description 'C99 little-endian.'
  template    Structle::Template.load(File.join(File.dirname(__FILE__), 'c99.template'))
end
