require "parslet"

module TieredCategoryExpressions
  class Parser < Parslet::Parser
    rule(:space)     { match('\s').repeat(1) }
    rule(:space?)    { space.maybe }
    rule(:negator)   { str("!") >> space? }

    rule(:sep)       { str(">") >> space? }
    rule(:isep)      { sep >> negator }
    rule(:sepsep)    { str(">>") >> space? }
    rule(:isepsep)   { sepsep >> negator }

    rule(:connector) { (isepsep | sepsep | isep | sep) }

    rule(:namesep)   { str("|") >> space? }

    rule(:word)      { (match["[:alnum:]"] | str("%")).repeat(1) >> space? }
    rule(:name)      { word.repeat(1).as(:name) }
    rule(:namelist)  { (name.repeat(1, 1) >> (namesep >> name).repeat).as(:namelist) }

    rule(:stop)      { str(".") >> space? }

    rule(:tier1)     { (connector | negator).maybe.as(:operator) >> namelist }
    rule(:tier)      { connector.as(:operator) >> namelist }
    rule(:tiers)     { tier.repeat >> (stop >> (tier.repeat(1, 1) >> tiers).as(:tail)).maybe }

    rule(:tce)       { space? >> (tier1.repeat(1, 1) >> tiers).as(:tiers) >> stop.maybe.as(:eoct) }

    root(:tce)
  end
end
