$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "tiered_category_expressions"
require_relative "./support/sql_helper"

RSpec.configure do |config|
  config.include SQLHelper
end
