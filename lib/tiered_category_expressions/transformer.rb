require "parslet"
require "tiered_category_expressions/name"
require "tiered_category_expressions/namelist"
require "tiered_category_expressions/tiers"
require "tiered_category_expressions/tail"
require "tiered_category_expressions/expression"

module TieredCategoryExpressions
  class Transformer < Parslet::Transform
    rule(:name => simple(:name)) do
      Name.new(name.to_s)
    end

    rule(:operator => simple(:op), :namelist => sequence(:names)) do
      Tier.build(op, names)
    end

    rule(:tail => sequence(:tiers)) do
      Tail.new(tiers)
    end

    rule(:tiers => sequence(:tiers), :eoct => simple(:eoct)) do
      Expression.new(tiers, strict: !!eoct)
    end
  end
end
