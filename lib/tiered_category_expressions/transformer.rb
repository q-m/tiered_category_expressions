require "parslet"
require "tiered_category_expressions/name"
require "tiered_category_expressions/namelist"
require "tiered_category_expressions/tiers"
require "tiered_category_expressions/tail"
require "tiered_category_expressions/expression"

module TieredCategoryExpressions
  class Transformer < Parslet::Transform
    rule(:name => simple(:name))    { Name.new(name.to_s) }
    rule(:tier => subtree(:tier))   { Tier.build(tier[:operator], tier[:namelist]) }
    rule(:tail => sequence(:tiers)) { Tail.new(tiers) }
    rule(:expr => subtree(:expr))   { Expression.new(expr[:tiers], strict: expr.has_key?(:eoct)) }
  end
end
