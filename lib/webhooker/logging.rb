require 'logger'
require 'webhooker/configuration'

module Logging
  # This is the magical bit that gets mixed into your classes
  def logger
    @logger ||= Logging.logger_for(self.class.name)
  end

  # Use a hash class-ivar to cache a unique Logger per class:
  @loggers = {}

  class << self
    def logger_for(classname)
      @loggers[classname] ||= configure_logger_for(classname)
    end

    def configure_logger_for(classname)
      logfile = Configuration.settings[:global][:logfile]
      logger = Logger.new(STDOUT)
      logger.progname = classname
      logger.debug "configured logger with logfile #{logfile}"
      logger
    end
  end
end
