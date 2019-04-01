module TieredCategoryExpressions
  class Namelist
    def initialize(names)
      @names = names.sort_by(&:to_s)
    end

    def to_s
      @names.join(" | ")
    end

    def as_regexp
      "(#{@names.map(&:as_regexp).join('|')})"
    end
  end
end
