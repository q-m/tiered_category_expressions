module TieredCategoryExpressions
  class Tail
    def initialize(tiers)
      @tiers = tiers
    end

    def to_s
      ". " + @tiers.join(" ")
    end

    def as_regexp
      "($|(#{@tiers.map(&:as_regexp).join}))"
    end

    def as_sql_like_query
      "%"
    end
  end
end
