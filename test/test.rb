require 'base64'
require_relative 'test_helper'

describe 'GET /' do
  it 'should request authentication' do
    get '/'
    last_response.status.must_equal 401
  end
  it 'should respond with authentication' do
    authorize "deployer", "Deploy1T"
    get '/'
    assert last_response.ok?
  end
end

