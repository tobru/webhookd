require 'sinatra'
require 'yaml'
require 'json'
require 'webhooker/version'

module Webhooker
  class App < Sinatra::Base

    # Sinatra configuration
    configure { set :show_exceptions, false }

    not_found do
      'Route not found. Do you know what you want to do?'
    end

    error 400 do
      'Payload type unknown'
    end

    error do |err|
        "There was an application error: #{err}"
    end

    ### Sinatra routes
    # we don't have anything to show
    get '/' do
        "I'm running. Nice, isn't it?"
    end

    post '/payload/:payloadtype' do
      begin
        load "webhooker/payloadtype/#{params[:payloadtype]}.rb"
      rescue LoadError
        halt 400
      end
      parser = ParsePayload.new(request.body.read)
      parser.parse
    end
  end
end
