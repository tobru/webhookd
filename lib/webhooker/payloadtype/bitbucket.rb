module Webhooker
  class ParsePayload
    def initialize(payload)
      @payload = payload
    end

    def parse
      require 'json'
      prepared = URI.unescape(@payload.gsub("payload=","").gsub("+"," "))
      json_parsed = JSON.parse(URI.unescape(prepared))

      data = Hash.new
      data[:type] = 'vcs'
      data[:source] = 'bitbucket'
      data[:repo_name] = json_parsed['repository']['name']
      data[:branch_name] = json_parsed['commits'][0]['branch']
      data[:author_name] = json_parsed['commits'][0]['author']
      data

      #"hi from bitbucket parser: #{data}"
    end
  end
end
