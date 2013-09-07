require 'protocol/template'

module Protocol
  class Language
    module Conventions
      def type     *name; studly_case *name        end
      def variable *name; snake_case  *name        end
      def constant *name; snake_case(*name).upcase end
      def function *name; snake_case  *name        end

      def studly_case *name
        snake_case(*name).split('_').map(&:capitalize).join
      end

      def snake_case *name
        name.flatten.compact.map(&:to_s).join('_').gsub(/([^A-Z_])([A-Z]+)/, '\1_\2').gsub(/[_.]+/, '_').downcase
      end
    end

    def apply package
      template = Template.load self.class.template
      template.extend self.class.const_get(:Conventions)
      template.apply package
    end

    class << self
      def language language = nil
        @language = language if language
        @language
      end

      def description description = nil
        @description = description if description
        @description
      end

      def template template = nil
        @template = template if template
        @template
      end

      def all
        (@@languages ||= [])
      end

      def find language
        all.find{|l| l.language.to_s.downcase.eql?(language.to_s.downcase) }
      end

      def inherited klass
        all << klass
      end
    end
  end
end
