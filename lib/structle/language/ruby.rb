require 'structle/language'

class Structle::Language::RubyPortable < Structle::Language
  module Conventions
    include Structle::Language::Conventions
    def type *names
      names.flatten.map{|n| studly_case(n)}.join('::')
    end
  end

  language    'ruby-portabe'
  description 'Ruby endian portable.'
  template    File.join(File.dirname(__FILE__), 'ruby.template')
end

#--
# Since this is pure Ruby at the moment in truth it's portable for now.
class Structle::Language::Ruby < Structle::Language::RubyPortable
  language    'ruby'
  description 'Ruby little-endian.'
  template    File.join(File.dirname(__FILE__), 'ruby.template')
end

