module Structle

  # Template
  #
  # \A\s*= Code
  # \A\s*- Silent code
  # \A\=   Literal =
  # \A\-   Literal -
  #
  # Template attempts to outdent silent code blocks so both the source and generated output can be correctly
  # indented. The caveats are:
  #
  # * Both source and output need to use the same indentation style.
  # * You can't use multi-line {} blocks (it's poor style anyway)
  # * You can't have trailing message passing on end keywords.
  #
  # Example:
  #   template = Template.new
  #   template.parse <<-TEMPLATE
  #   - data.each do |v|
  #     = 'value: %s' % v
  #   - end
  #   TEMPLATE
  #
  #   puts template.apply(%w{foo bar baz})
  #   #=> "value: foo\nvalue: bar\nvalue: baz\n"
  #--
  # TODO: This could be a library/gem on its own.
  # TODO: The output handling is rough and probably has loads of edge cases.
  # TODO: There is probably no need for Compiled.
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

    CODE         = %r{^\s*(?<!\\)=\s*}
    SILENT_CODE  = %r{^\s*(?<!\\)-\s*}
    BLOCK_OPEN   = %r{(?:^#{SILENT_CODE}(?<keyword>if|begin|case|unless|while|def)\b)|(?:(?<keyword>do)\s*\|\s*[^\|]*\|$)}
    BLOCK_CLOSE  = %r{^#{SILENT_CODE}(?<keyword>end)\b}

    def initialize indent = '  '
      @indent = indent
    end

    def parse source, file = nil
      depth = 0
      source.each_line.inject(Compiled.new(file)) do |compiled, line|
        margin = line.match(/^\s*/)[0]
        indent = margin.size

        depth += 1 if BLOCK_OPEN.match(line)
        case line.chomp!
          when CODE        then compiled << %q{%sself << '%%*s%%s' %% [%s, '', (%s).to_s]} % [@indent * depth, justify(indent, depth, margin).size, line.sub(CODE, '')]
          when SILENT_CODE then compiled << %q{%s%s}                                       % [@indent * depth, line.sub(SILENT_CODE, '')]
          else                  compiled << %q{%sself << %%Q`%s`}                          % [@indent * depth, justify(indent, depth, line.gsub(/`/, '\`'))]
        end
        depth -= 1 if BLOCK_CLOSE.match(line)
        compiled
      end
    end

    def self.load file
      new.parse File.read(file), file
    end

    protected
      def justify indent, depth, line
        depth == 0 ? line : line.sub(/^#{Regexp.escape(@indent * depth)}/, '')
      end
  end
end

