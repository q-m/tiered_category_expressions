module TieredCategoryExpressions
  class Tier < Struct.new(:operator, :namelist)
    def to_s
      "#{operator} #{namelist}"
    end

    def as_regexp
      raise NotImplementedError, "subclasses of Tier must implement `#as_regexp`"
    end

    class Child < Tier
      def initialize(namelist)
        super(">", namelist)
      end

      def as_regexp
        "#{namelist.as_regexp}>"
      end
    end

    class IChild < Tier
      def initialize(namelist)
        super("> !", namelist)
      end

      def as_regexp
        "(?!#{namelist.as_regexp}>).+>"
      end
    end

    class Descendant < Tier
      def initialize(namelist)
        super(">>", namelist)
      end

      def as_regexp
        "(.+>)*#{namelist.as_regexp}>"
      end
    end

    class IDescendant < Tier
      def initialize(namelist)
        super(">> !", namelist)
      end

      def as_regexp
        "(?!(.+>)*#{namelist.as_regexp}>).+>"
      end
    end
  end
end
