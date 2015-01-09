require 'sinatra/base'
require 'yaml'
require 'json'
require 'webhooker/version'
require 'webhooker/command_runner'
require 'webhooker/logging'
require 'webhooker/configuration'

module Webhooker
  class App < Sinatra::Base
    Configuration.load!('/home/tobru/src/wuala/webhooker/config/example.yml')
    include Logging

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
      logger.info "incoming request from #{request.ip} for payload type #{params[:payloadtype]}"

      begin
        logger.debug "try to load webhooker/payloadtype/#{params[:payloadtype]}.rb"
        load "webhooker/payloadtype/#{params[:payloadtype]}.rb"
      rescue LoadError
        logger.error "file not found: webhooker/payloadtype/#{params[:payloadtype]}.rb"
        halt 400
      end

      parser = ParsePayload.new(request.body.read)
      parsed_data = parser.parse

      command_runner = Commandrunner.new('echo hallo')
      command_runner.run

      # output to the requester
      "it's coming from #{parsed_data[:source]}"
    end
  end
end
