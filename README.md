# Tiered Category Expressions

Work with TCEs in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tiered_category_expressions', github: "q-m/tiered_category_expressions"
```

And then execute:

    $ bundle

<!--
Or install it yourself as:

    $ gem install tiered_category_expressions
-->

## Documentation

  - [Library documentation](https://developers.thequestionmark.org/tiered_category_expressions)
  - [TCE language reference](https://developers.thequestionmark.org/tiered_category_expressions/file.LANGREF.html)

## Usage

```ruby
tce = TCE("groceries > nonfood | pharmacy >> !baby formula")
# => TieredCategoryExpressions::Expression[groceries > nonfood | pharmacy >> !baby formula]

tce.matches?(["Groceries", "Non-food", "Cleaning", "Soap"])
# => true

tce.matches?(["Groceries", "Non-food", "Baby", "Baby formula"])
# => false

tce.matches?(["Groceries", "Pharmacy", "Baby", "Pacifiers"])
# => true

tce.to_regexp
# => /^(groceries)>(nonfood|pharmacy)>(?!(.+>)*(babyformula)>).+>/i

tce.as_regexp
# => "^(groceries)>(nonfood|pharmacy)>(?!(.+>)*(babyformula)>).+>"

TCE("groceries > nonfood") > TCE("baby") > ">> pacifiers"
# => TieredCategoryExpressions::Expression[groceries > nonfood > baby >> pacifiers]
```

## Development

Run `rake spec` to run the tests. You can also run `bundle console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, run `bundle exec rake docs`, which will build and commit the documentation, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/q-m/tiered_category_expressions.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
