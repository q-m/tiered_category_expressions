require "tiered_category_expressions/util"

module TieredCategoryExpressions
  class Name
    def initialize(name)
      @name = name.strip.gsub(/%+/, "%").gsub(/\s+/, " ")
      @normalized_name = Util.transliterate(@name.downcase).tr(" ", "")
    end

    def to_s
      @name
    end

    def as_regexp
      @normalized_name.gsub(/%/, "[^>]*")
    end

    def as_sql_like_query
      @normalized_name
    end
  end
end
