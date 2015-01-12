ENV['RACK_ENV'] = 'test'

require 'bundler'
Bundler.require :default, :test

require 'minitest/autorun'
require 'rack/test'
require_relative '../lib/webhooker/app.rb'

include Rack::Test::Methods

def app
  Webhooker::App
end
