module Webhooker
  class ParsePayload
    def initialize(payload)
      @payload = payload
    end

    def parse
      "hi from bitbucket parser: #{@payload}"
    end
  end
end
