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
    rule(:namelist)  { (name >> (namesep >> name).repeat).as(:namelist) }

    rule(:tce)       { space? >> (((connector | negator).as(:operator).maybe >> namelist).as(:tier) >> (connector.as(:operator) >> namelist).as(:tier).repeat).as(:expression) }
    root(:tce)
  end
end
