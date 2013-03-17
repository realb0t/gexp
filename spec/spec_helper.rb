require "bundler"
require 'bundler/setup'
require 'state_machine/core'
require 'gexp'

ENV["MONGO_URL"] ||= ENV["MONGOHQ_URL"] || "mongodb://localhost/gexp_test"

RSpec.configure do |conf|
  #conf.include Rack::Test::Methods
  conf.include Mongoid::Matchers
  conf.mock_with :rr
  conf.color_enabled = true
end
