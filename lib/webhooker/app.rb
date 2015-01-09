require 'sinatra/base'
require 'yaml'
require 'json'
require 'erb'
require 'webhooker/version'
require 'webhooker/command_runner'
require 'webhooker/logging'
require 'webhooker/configuration'

module Webhooker
  class App < Sinatra::Base
    Configuration.load!('config/example.yml')
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

      # see if the payloadtype is known
      if Configuration.settings.has_key?(parsed_data[:type].to_sym)
        case parsed_data[:type]
          when 'vcs'
            command = nil
            # is the repo name configured?
            if Configuration.settings[:vcs].has_key?(parsed_data[:repo_name].to_sym)
              repo_config = Configuration.settings[:vcs][parsed_data[:repo_name].to_sym]
              # is the branch configured?
              if repo_config.has_key?(parsed_data[:branch_name].to_sym)
                logger.debug "branch is explicitely configured"
                branch_config = repo_config[parsed_data[:branch_name].to_sym]
                command = branch_config[:command]
              # is there a catch all rule?
              elsif repo_config.has_key?(:_all)
                logger.debug "branch is not not explicitely configured, but there is a '_all' rule"
                branch_config = repo_config[:_all]
                command = branch_config[:command]
              # don't know what to do
              else
                logger.error "no configuration for branch '#{parsed_data[:branch_name]}' found"
                halt 500
              end
              if command
                # vars for ERB binding
                branch_name = parsed_data[:branch_name]
                parsed_command = ERB.new(command).result(binding)
                command_runner = Commandrunner.new(parsed_command)
                command_runner.run
              else
                logger.error "no command configured"
                halt 500
              end
            # is there a catch all rule?
            elsif Configuration.settings[:vcs].has_key?(:_all)
              logger.info "repository not explicitely configured, but there is a '_all' rule"
            else
              logger.error "the repository '#{parsed_data[:repo_name]}' is not configured"
              halt 500
            end
          else
            logger.fatal "webhook payload type #{parsed_data[:type]} unknown"
            halt 500
        end
      else
        logger.info "webhook payload of type #{parsed_data[:type]} not configured"
      end


      # output to the requester
      "it's coming from #{parsed_data[:source]}"
    end
  end
end
