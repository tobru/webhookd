require 'thor'

module Webhooker
  class CLI < Thor
    include Thor::Actions

    attr_reader :name

    desc "start", "Starts the webhooker server"
    method_option :config_file, :desc => "Path to the configuration file"
    def start(*args)
      port_option = args.include?('-p') ? '' : ' -p 8088'
      args = args.join(' ')
      command = "bundle exec thin -R config.ru start#{port_option} #{args}"
      command.prepend "export CONFIG_FILE=#{options[:config_file]}; " if options[:config_file]
      begin
        run_command(command)
      rescue SystemExit, Interrupt
        puts "Program interrupted"
        exit
      end
    end

    desc "stop", "Stops the thin server"
    def stop
      command = "bundle exec thin stop"
      run_command(command)
    end

    # map some commands
    map 's' => :start

    private

    def run_command(command)
      system(command)
    end

    def require_file(file)
      require file
    end
  end
end

