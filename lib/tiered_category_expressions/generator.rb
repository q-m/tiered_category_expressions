require "tiered_category_expressions/exceptions"
require "tiered_category_expressions/expression"

module TieredCategoryExpressions
  module Generator
    class << self
      # Generates a basic TCE that matches the given category. Returns nil if no valid TCE can be generated.
      #
      # @example
      #  TieredCategoryExpressions::Generator.call(["Non-food", "Baby", "Baby formula"])
      #  # => TieredCategoryExpressions::Expression[Nonfood > Baby > Baby formula]
      #
      # @param category [Array<String>]
      # @param strict [Boolean] If +true+ is given then the resulting TCE will not match subcategories of the given
      #   category.
      # @return [Expression, nil]
      #
      def call(category, strict: false)
        return if category.empty?

        tiers = category.map { |t| sanitize_name(t) or return nil }
        expression = tiers.join(">")
        expression << "." if strict

        TieredCategoryExpressions::TCE(expression)
      end

      private

      def sanitize_name(str)
        str = str.gsub(/[^[:alnum:]\s]/, "") # remove non-word characters
                 .gsub(/\s+/, " ")           # squish whitespace
                 .strip

        return if str == ""

        str
      end
    end
  end
end
