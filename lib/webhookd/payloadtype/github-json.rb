require 'webhookd/logging'
module Webhookd
  class ParsePayload

    include Logging

    def initialize(payload)
      @payload = payload
    end

    def parse
      require 'json'
      logger.debug 'parsing payload type github-json'

      json_parsed = JSON.parse(@payload)
      logger.debug "raw received data: #{json_parsed}"

      # loop through commits to find the author
      author_name = '_notfound'
      json_parsed['commits'].each do |commit|
        if commit['author']
          author_name = commit['author']['name']
          break
        end
      end

      data = Hash.new
      data[:type] = 'vcs'
      data[:source] = 'github'
      data[:repo_name] = json_parsed['repository']['name']
      data[:branch_name] = json_parsed['ref'].split("/")[2]
      data[:author_name] = author_name

      logger.info "parsed from the github-json data: #{data}"

      # return the hash
      data
    end
  end
end
