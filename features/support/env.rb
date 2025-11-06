require "cucumber/rails"
require "rspec/expectations"

World(RSpec::Matchers)

ActionController::Base.allow_rescue = false

Cucumber::Rails::Database.javascript_strategy = :truncation
