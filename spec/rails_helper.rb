# frozen_string_literal: true
ENV["RAILS_ENV"] = "test"
# Coverage
require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'capybara'

require 'fixtures/dummy-app/config/environment'

require 'rspec/rails'
require 'spec_helper'

RSpec.configure do |config|
 config.include Capybara::DSL
end
