module TieredCategoryExpressions
  # @internal TODO Deal with digits and dashes ("1-3 months" != "13months")
  module Preprocessor
    class << self
      # Converts a category to a string suitable for matching with TCE regexps.
      #
      # @example
      #  category = ["Non-food", "Cosmetics"]
      #  preprocessed_category = TieredCategoryExpressions::Preprocessor.call(category)
      #  TCE("nonfood > cosmetics").to_regexp.match? preprocessed_category
      #  # => true
      #
      # @param category [Array<String>]
      # @return [String]
      #
      def call(category)
        return "" if category.empty?

        category.map { |t| sanitize_name(t) }.join(">") + ">"
      end

      private

      def sanitize_name(str)
        str = Util.transliterate(str)
        str.downcase.gsub(/[^a-z0-9]/, "") # remove all non word & non space characters
      end
    end
  end
end
