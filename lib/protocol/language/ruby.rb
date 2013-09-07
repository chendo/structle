require 'protocol/language'

class Protocol::Language::RubyPortable < Protocol::Language
  module Conventions
    include Protocol::Language::Conventions

    def class_case *names
      names.flatten.map{|n| studly_case(n)}.join('::')
    end

    # TODO: More helpers than conventions.
    def struct_members members
      members.map{|m| ':%s' % m.name}.join(', ')
    end

    def struct_members_format members
      members.map{|m| struct_format(m)}.join
    end

    def struct_format member
      case member
        when Protocol::User   then member.klass.kind_of?(Protocol::Struct) ? 'a%s' % member.size : 'C'
        when Protocol::Bytes  then 'a%s' % member.size
        when Protocol::Bool   then 'C'
        when Protocol::Float  then 'e'
        when Protocol::Double then 'E'
        when Protocol::Uint8  then 'C'
        when Protocol::Uint16 then 'S<'
        when Protocol::Uint32 then 'L<'
        when Protocol::Uint64 then 'Q<'
        when Protocol::Int8   then 'c'
        when Protocol::Int16  then 's<'
        when Protocol::Int32  then 'l<'
        when Protocol::Int64  then 'q<'
      end
    end
  end

  language    'ruby-portabe'
  description 'Ruby endian portable.'
  template    File.join(File.dirname(__FILE__), 'ruby.template')
end

#--
# Since this is pure Ruby at the moment in truth it's portable for now.
class Protocol::Language::Ruby < Protocol::Language::RubyPortable
  language    'ruby'
  description 'Ruby little-endian.'
  template    File.join(File.dirname(__FILE__), 'ruby.template')
end

