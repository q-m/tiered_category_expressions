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

  desc "Commit changes to the ./docs folder"
  task :commit do
    message = "Update documentation for v#{TieredCategoryExpressions::VERSION}"
    print `git commit --only ./docs --message '#{message}'`
  end

  desc "View the YARD documentation in your browser"
  task :view do
    print `open ./docs/index.html`
  end

  desc "Build and view the YARD documentation"
  task :bv => [:build, :view]
end

desc "Build and commit the YARD documentation"
task :docs => ["docs:build", "docs:commit"]
