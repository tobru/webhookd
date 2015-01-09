require 'yaml'

module Configuration
  # we don't want to instantiate this class - it's a singleton,
  # so just keep it as a self-extended module
  extend self

  @settings = {}
  attr_reader :settings

  def load!(filename, options = {})
    @settings = symbolize_keys(YAML::load_file(filename))
  end

  def symbolize_keys(hash)
    hash.inject({}){|result, (key, value)|
      new_key = case key
                when String then key.to_sym
                else key
                end
      new_value = case value
                  when Hash then symbolize_keys(value)
                  else value
                  end
      result[new_key] = new_value
      result
    }
  end

end
