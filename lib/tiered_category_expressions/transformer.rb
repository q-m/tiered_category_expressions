require "parslet"
require "tiered_category_expressions/name"
require "tiered_category_expressions/namelist"
require "tiered_category_expressions/tiers"
require "tiered_category_expressions/expression"

module TieredCategoryExpressions
  class Transformer < Parslet::Transform
    rule(:name => simple(:name)) { Name.new(name.to_s) }

    rule(:tier => subtree(:tier)) do
      klass = case tier[:operator]&.to_s&.tr(" ", "")
      when ">",  nil then Tier::Child
      when ">!", "!" then Tier::IChild
      when ">>"      then Tier::Descendant
      when ">>!"     then Tier::IDescendant
      else raise "no such operator #{tier[:operator].inspect}"
      end

      namelist = Namelist.new([tier[:namelist]].flatten)
      klass.new(namelist)
    end

    rule(:expression => subtree(:tiers)) { Expression.new([tiers].flatten) }
  end
end
