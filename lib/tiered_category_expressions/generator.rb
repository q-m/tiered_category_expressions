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
      # @return [Expression, nil]
      #
      def call(category)
        return if category.empty?

        tiers = category.map { |t| sanitize_name(t) or return nil }

        TieredCategoryExpressions::TCE(tiers.join(" > "))
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
