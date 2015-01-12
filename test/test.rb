require 'base64'
require_relative 'test_helper'

describe 'GET /' do
  it 'should request authentication' do
    get '/'
    last_response.status.must_equal 401
  end
end

