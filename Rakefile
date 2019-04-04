require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :docs do
  desc "Build the YARD documentation"
  task :build do
    title = "tiered_category_expressions (v#{TieredCategoryExpressions::VERSION})"
    print `bundle exec yardoc --title '#{title}'`
  end

  desc "View the YARD documentation in your browser"
  task :view do
    print `open ./doc/index.html`
  end
end

desc "Build and view the YARD documentation"
task :docs => ["docs:build", "docs:view"]
