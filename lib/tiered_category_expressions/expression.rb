require "tiered_category_expressions/parser"
require "tiered_category_expressions/transformer"
require "tiered_category_expressions/preprocessor"
require "tiered_category_expressions/util"

module TieredCategoryExpressions
  class ParseError < StandardError; end

  # Converts input to an {Expression}.
  #
  # @param expression [Expression, #to_s]
  # @return [Expression]
  # @raise [ParseError] on input input
  #
  def self.Expression(expression)
    case expression
    when TieredCategoryExpressions::Expression then expression
    else TieredCategoryExpressions::Expression.parse(expression.to_s)
    end
  end

  class Expression
    # @param str [String] Tiered category expression to parse
    # @return [Expression]
    # @raise [ParseError] on input input
    #
    def self.parse(str)
      tree = TieredCategoryExpressions::Parser.new.parse(str)
      TieredCategoryExpressions::Transformer.new.apply(tree)
    rescue Parslet::ParseFailed => e
      deepest = Util.deepest_parse_failure_cause(e.parse_failure_cause)
      _, column = deepest.source.line_and_column(deepest.pos)
      raise ParseError, "unexpected input at character #{column}"
    end

    # @!visibility private
    def initialize(tiers)
      @tiers = tiers
    end

    # @!visibility private
    def inspect
      "TieredCategoryExpressions::Expression[#{self}]"
    end

    # @return [String] String representation of the expression
    def to_s
      @tiers.join(" ").sub(/^>(?!>)\s*/, "") # Initial ">" is implied (but ">>" is not)
    end

    # @return [Regexp] Regexp representation of the expression as a string (does not include flags)
    def as_regexp
      "^#{@tiers.map(&:as_regexp).join}"
    end

    # @return [String] Regexp representation of the expression
    def to_regexp
      /#{as_regexp}/i
    end

    # Matches the expression with the given category.
    #
    # @param category [Array<String>] Category to match
    # @return [Boolean]
    def matches?(category)
      to_regexp.match?(Preprocessor.call(category))
    end
    alias === matches?

    # Returns +true+ if both expressions are equal. Expressions are considered equal if they match the same categories.
    #
    # @param other [Expression, #to_s]
    # @return [Boolean]
    #
    def ==(other)
      to_regexp == TCE(other).to_regexp
    end

    # Concatenates two expressions.
    #
    # @example
    #  TCE("foo") > "!bar" > TCE(">> baz")
    #  # => TieredCategoryExpressions::Expression[foo > !bar >> baz]
    #
    # @param other [Expression, #to_s]
    # @return [Expression]
    #
    def >(other)
      self.class.new(@tiers + TCE(other).tiers)
    end

    protected

    def tiers
      @tiers
    end
  end
end
