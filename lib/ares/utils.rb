require 'cgi/util'

module Ares
  module Utils
    module Buildable
      # Creates attribute accessor and setter.
      #
      # Accepts value and sets to instance variable, then returns self.
      # Without param returns current value.
      #
      # @example
      #   class TestBuilder
      #     extends Buildable
      #     attr_builder :foo, :bar
      #   end
      #
      #   builder = TestBuilder.new
      #   builder.foo('foo').bar('bar') # => #<TestBuilder:0x890236c>
      #
      #   builder.foo # => 'foo'
      #   builder.bar # => 'bar'
      #
      # @param attrs [Array<Symbol>] Attributes to create build methods for.
      # @!macro [attach] attr_builder
      #   Set attribute value and return self.
      #
      #   Without argument returns attribute value.
      #   @param value [] Set the $1 attribute
      #   @returns [] the $1 attribute
      def attr_builder(*attrs)
        attrs.each do |attr|
          define_method(attr) do |*value|
            if value.size == 0
              instance_variable_get "@#{attr}"
            else
              instance_variable_set "@#{attr}", value.first
              self
            end
          end
        end
      end
    end

    def self.make_query(hash)
      return hash.to_query if hash.respond_to? :to_query

      hash.map do |key, value|
        CGI.escape(key.to_s) + '=' + CGI.escape(value.to_s)
      end.sort.join '&'
    end
  end
end
