module Protocol

  # Template
  #
  # HAML-ish templating without the HTML markup so it's useful for code generation.
  #
  # \A\s*= Code
  # \A\s*- Silent code
  # \A\=   Literal =
  # \A\-   Literal -
  #
  # Template attempts to outdent silent code blocks so both the source and generated output can be correctly
  # indented. The caveat is both source and output need to use the same indentation style.
  #
  # Example:
  #   template = Template.new
  #   template.parse <<-TEMPLATE
  #   - data.each do |v|
  #     = 'value: %s' % v
  #   TEMPLATE
  #
  #   puts template.apply(%w{foo bar baz})
  #   #=> "value: foo\nvalue: bar\nvalue: baz\n"
  #--
  # TODO: This could be a library/gem on its own.
  class Template
    class Compiled
      def initialize file
        @__file__ = file.to_s
      end

      def apply context
        clone.evaluate context
      end

      def << line
        (@__out__ ||= '') << line << $/
      end

      def data
        @__data__
      end

      protected
        def evaluate data
          @__data__ = data
          source    = @__out__.slice!(0, @__out__.size)
          eval source, binding, @__file__, 0
          @__out__
        end
    end

    Stack = ::Struct.new(:indent, :close)

    CODE         = %r{^\s*(?<!\\)=\s*}
    SILENT_CODE  = %r{^\s*(?<!\\)-\s*}
    BLOCK_OPEN   = %r{(?:^#{SILENT_CODE}(?<keyword>if|begin|case|unless)\b)|(?:(?<keyword>do|\{)\s*\|\s*[^\|]*\|$)}
    BLOCK_MIDDLE = %r{^#{SILENT_CODE}(?:else|elsif|rescue|ensure|end|when)}

    def initialize indent = '  '
      @indent, @stack = indent, []
    end

    def parse source, file = nil
      compiled = Compiled.new file
      source.each_line do |line|
        margin = line.match(/^\s*/)[0]
        indent = margin.size

        block_close(compiled, indent, line) unless line.match(BLOCK_MIDDLE)
        case line.chomp!
          when CODE        then compiled << %q{self << '%%*s%%s' %% [%s, '', (%s).to_s]} % [justify(indent, margin).size, line.sub(CODE, '')]
          when SILENT_CODE then compiled << justify(indent, line.sub(SILENT_CODE, ''))
          else                  compiled << %Q{__out__ = <<-__out__\n%s\n__out__\nself << __out__.chomp} % justify(indent, line)
        end
        block_open(compiled, indent, line)
      end

      block_close compiled, 0, ''
      compiled
    end

    def self.load file
      new.parse File.read(file), file
    end

    protected
      def justify indent, line
        @stack.empty? ? line : line.sub(/^#{Regexp.escape(@indent * @stack.size)}/, '')
      end

      def block_open compiled, indent, line
        BLOCK_OPEN.match(line) do |match|
          @stack.push Stack.new(indent, (match[:keyword] == '{' ? '}' : 'end'))
        end
      end

      def block_close compiled, indent, line
        while !@stack.empty? and indent <= @stack.last.indent
          compiled << justify(indent, @stack.pop.close)
        end
      end
  end
end

