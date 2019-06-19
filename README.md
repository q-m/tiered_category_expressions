<div style="float: right">
<a href="https://badge.fury.io/rb/tiered_category_expressions"><img src="https://badge.fury.io/rb/tiered_category_expressions.svg" alt="Rubygem" height="18" /></a>
<a href="https://travis-ci.org/q-m/tiered_category_expressions/"><img src="https://travis-ci.org/q-m/tiered_category_expressions.svg?branch=master" alt="Travis CI" height="18"/></a>
</div>

# Tiered Category Expressions

Work with TCE v1.1 in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tiered_category_expressions'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tiered_category_expressions

And require with:

```ruby
require 'tiered_category_expressions'
```

Or, if you don't want the `TCE()` alias in the global namespace, require with:

```ruby
require 'tiered_category_expressions/core'
```

## Documentation

  - [Library documentation](https://www.rubydoc.info/gems/tiered_category_expressions/)
  - [TCE language reference](https://www.rubydoc.info/gems/tiered_category_expressions/file/LANGREF.md)

## Usage examples

```ruby
tce = TCE("groceries > nonfood | pharmacy >> !baby formula")
# => TieredCategoryExpressions::Expression

tce.matches?(["Groceries", "Non-food", "Cleaning", "Soap"])
# => true

tce.matches?(["Groceries", "Non-food", "Baby", "Baby formula"])
# => false

tce.matches?(["Groceries", "Pharmacy", "Baby", "Pacifiers"])
# => true

tce.to_regexp
# => Regexp

tce.as_regexp
# => String

TCE("groceries > nonfood") > TCE("baby") > ">> pacifiers"
# => TieredCategoryExpressions::Expression
```

## Development

Run `rake spec` to run the tests. You can also run `bundle console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb` and run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/q-m/tiered_category_expressions.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
