require "tiered_category_expressions/util"

module TieredCategoryExpressions
  class Name
    def initialize(name)
      @name = name.strip.gsub(/\s+/, " ")
    end

    def to_s
      @name
    end

    def as_regexp
      Util.transliterate(@name.downcase).tr(" ", "").gsub(/%/, ".*")
    end
  end
end
