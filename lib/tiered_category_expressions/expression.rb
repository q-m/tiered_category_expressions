require "tiered_category_expressions/parser"
require "tiered_category_expressions/transformer"
require "tiered_category_expressions/preprocessor"
require "tiered_category_expressions/generator"
require "tiered_category_expressions/util"
require "tiered_category_expressions/exceptions"

module TieredCategoryExpressions
  class << self
    # Converts input to an {Expression}.
    #
    # @param expression [Expression, #to_s]
    # @return [Expression]
    # @raise [ParseError] Raises if TCE syntax is invalid
    #
    def Expression(expression)
      case expression
      when TieredCategoryExpressions::Expression then expression
      else TieredCategoryExpressions::Expression.parse(expression.to_s)
      end
    end
    alias TCE Expression
  end

  class Expression
    # @param str [String] Tiered category expression to parse
    # @return [Expression]
    # @raise [ParseError] Raises if TCE syntax is invalid
    #
    def self.parse(str)
      tree = Parser.new.parse(str)
      Transformer.new.apply(tree)
    rescue Parslet::ParseFailed => e
      deepest = Util.deepest_parse_failure_cause(e.parse_failure_cause)
      _, column = deepest.source.line_and_column(deepest.pos)
      raise ParseError, "unexpected input at character #{column}"
    end

    # @!visibility private
    def initialize(tiers, strict:)
      @tiers = tiers
      @strict = strict
    end

    # @!visibility private
    def inspect
      "TieredCategoryExpressions::Expression[#{self}]"
    end

    # @param implied_root [Boolean] If +true+ no leading ">" is included.
    # @return [String] String representation of the expression
    def to_s(implied_root: true)
      str = @tiers.join(" ")
      str << "." if @strict
      str = str.sub(/^>(?!>)\s*/, "") if implied_root # Initial ">" is implied (but ">>" is not)
      str
    end

    # @return [Regexp] Regexp representation of the expression as a string (does not include flags)
    def as_regexp
      "^#{@tiers.map(&:as_regexp).join}#{'$' if @strict}"
    end

    # @return [String] Regexp representation of the expression
    def to_regexp
      /#{as_regexp}/i
    end

    # Matches the expression with the given category.
    #
    # @param category [Array<String>] Category to match
    # @return [Boolean]
    #
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
      to_regexp == TieredCategoryExpressions::TCE(other).to_regexp
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
      TieredCategoryExpressions::TCE(to_s + TieredCategoryExpressions::TCE(other).to_s(implied_root: false))
    end

    # Returns an SQL LIKE query that may be used to speed up certain SQL queries.
    #
    # SQL queries that involve matching some input against stored TCE regexps can be slow. Possibly, they can be
    # optimized by applying a much faster LIKE query first, which reduces the number of regexps to apply. The LIKE
    # query alone can still yield false positives, so it must be combined with the corresponding regexp.
    #
    # For instance:
    #
    #  SELECT * FROM mappings WHERE 'foo>bar>baz>' LIKE tce_like_query AND 'foo>bar>baz>' ~ tce_regexp
    #
    # Can be much faster than:
    #
    #  SELECT * FROM mappings WHERE 'foo>bar>baz>' ~ tce_regexp
    #
    # Depending on the TCEs in the _mappings_ table.
    #
    def as_sql_like_query
      q = @tiers.map(&:as_sql_like_query).join
      q += "%" unless @strict || q.end_with?("%")
      q
    end

    protected

    def tiers
      @tiers
    end
  end
end
