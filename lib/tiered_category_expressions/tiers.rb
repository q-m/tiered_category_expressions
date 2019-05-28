module TieredCategoryExpressions
  class Tier < Struct.new(:operator, :namelist)
    def self.build(operator, names)
      klass = case operator&.to_s&.tr(" ", "")
      when ">",  nil then Child
      when ">!", "!" then IChild
      when ">>"      then Descendant
      when ">>!"     then IDescendant
      else raise "no such operator #{operator.inspect}"
      end

      namelist = Namelist.new(names)
      klass.new(namelist)
    end

    def to_s
      "#{operator} #{namelist}"
    end

    def as_regexp
      raise NotImplementedError, "subclasses of Tier must implement `#as_regexp`"
    end

    def as_sql_like_query
      raise NotImplementedError, "subclasses of Tier must implement `#as_sql_like_query`"
    end

    class Child < Tier
      def initialize(namelist)
        super(">", namelist)
      end

      def as_regexp
        "#{namelist.as_regexp}>"
      end

      def as_sql_like_query
        "#{namelist.as_sql_like_query}>"
      end
    end

    class IChild < Tier
      def initialize(namelist)
        super("> !", namelist)
      end

      def as_regexp
        "(?!#{namelist.as_regexp}>)[a-z0-9]+>"
      end

      def as_sql_like_query
        "%>"
      end
    end

    class Descendant < Tier
      def initialize(namelist)
        super(">>", namelist)
      end

      def as_regexp
        "([a-z0-9]+>)*#{namelist.as_regexp}>"
      end

      def as_sql_like_query
        "%#{namelist.as_sql_like_query}>".gsub(/%+/, "%")
      end
    end

    class IDescendant < Tier
      def initialize(namelist)
        super(">> !", namelist)
      end

      def as_regexp
        "(?!([a-z0-9]+>)*#{namelist.as_regexp}>)([a-z0-9]+>)+"
      end

      def as_sql_like_query
        "%>"
      end
    end
  end
end
